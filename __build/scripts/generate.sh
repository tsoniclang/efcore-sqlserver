#!/bin/bash
# Generate TypeScript declarations for Microsoft.EntityFrameworkCore.SqlServer (+ dependencies) from NuGet packages.
#
# Prerequisites:
#   - .NET 10 SDK installed
#   - tsbindgen repository cloned at ../tsbindgen (sibling directory)
#   - @tsonic/dotnet cloned at ../dotnet (sibling directory)
#   - @tsonic/microsoft-extensions cloned at ../microsoft-extensions (sibling directory)
#   - @tsonic/efcore cloned at ../efcore (sibling directory)
#
# Usage:
#   ./__build/scripts/generate.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TSBINDGEN_DIR="$PROJECT_DIR/../tsbindgen"
DOTNET_LIB="$PROJECT_DIR/../dotnet"
EXT_LIB="$PROJECT_DIR/../microsoft-extensions"
EFCORE_LIB="$PROJECT_DIR/../efcore"
REF_DIR="$PROJECT_DIR/__build/ref"

DOTNET_VERSION="${DOTNET_VERSION:-10.0.1}"
DOTNET_HOME="${DOTNET_HOME:-$HOME/.dotnet}"
NETCORE_RUNTIME_PATH="$DOTNET_HOME/shared/Microsoft.NETCore.App/$DOTNET_VERSION"

echo "================================================================"
echo "Generating EF Core SQL Server TypeScript Declarations"
echo "================================================================"
echo ""
echo "Configuration:"
echo "  .NET Runtime:       $NETCORE_RUNTIME_PATH"
echo "  BCL Library:        $DOTNET_LIB (external reference)"
echo "  Extensions Library: $EXT_LIB (external reference)"
echo "  EF Core Library:    $EFCORE_LIB (external reference)"
echo "  tsbindgen:          $TSBINDGEN_DIR"
echo "  Ref project:        $REF_DIR"
echo "  Output:             $PROJECT_DIR"
echo "  Naming:             JS (camelCase)"
echo ""

if [ ! -d "$NETCORE_RUNTIME_PATH" ]; then
    echo "ERROR: .NET runtime not found at $NETCORE_RUNTIME_PATH"
    exit 1
fi

for dir in "$TSBINDGEN_DIR" "$DOTNET_LIB" "$EXT_LIB" "$EFCORE_LIB"; do
    if [ ! -d "$dir" ]; then
        echo "ERROR: Missing required repo at $dir"
        exit 1
    fi
done

if [ ! -f "$REF_DIR/ref.csproj" ]; then
    echo "ERROR: Reference project not found at $REF_DIR/ref.csproj"
    exit 1
fi

echo "[1/4] Cleaning output directory..."
cd "$PROJECT_DIR"

find . -maxdepth 1 -type d \
    ! -name '.' \
    ! -name '.git' \
    ! -name '.tests' \
    ! -name 'node_modules' \
    ! -name '__build' \
    -exec rm -rf {} \; 2>/dev/null || true

rm -f *.d.ts *.js families.json 2>/dev/null || true
rm -rf __internal Internal internal 2>/dev/null || true

echo "  Done"

echo "[2/4] Restoring reference project packages..."
dotnet restore "$REF_DIR/ref.csproj" --verbosity quiet
echo "  Done"

echo "[3/4] Building reference project..."
dotnet build "$REF_DIR/ref.csproj" -c Release --no-restore --verbosity quiet
echo "  Done"

echo "[4/4] Building + running tsbindgen..."
cd "$TSBINDGEN_DIR"
dotnet build src/tsbindgen/tsbindgen.csproj -c Release --verbosity quiet

REF_OUT="$REF_DIR/bin/Release/net10.0"
REF_DLLS=( "$REF_OUT"/*.dll )
if [ ! -f "${REF_DLLS[0]}" ]; then
    echo "ERROR: No dlls found in $REF_OUT"
    exit 1
fi

GEN_ARGS=()
for dll in "${REF_DLLS[@]}"; do
    GEN_ARGS+=( -a "$dll" )
done

# EF Core includes generic `new()` constraints that TypeScript cannot represent for instance-type generics.
# We explicitly allow this constraint loss to unblock generation (emitted as warnings by tsbindgen).
dotnet run --project src/tsbindgen/tsbindgen.csproj --no-build -c Release -- \
    generate "${GEN_ARGS[@]}" -d "$NETCORE_RUNTIME_PATH" -o "$PROJECT_DIR" \
    --allow-constructor-constraint-loss \
    --lib "$DOTNET_LIB" \
    --lib "$EXT_LIB" \
    --lib "$EFCORE_LIB" \
    --naming js

echo ""
echo "================================================================"
echo "Generation Complete"
echo "================================================================"
