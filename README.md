# @tsonic/efcore-sqlserver

TypeScript declarations and CLR binding metadata for the EF Core SQL Server
provider (`Microsoft.EntityFrameworkCore.SqlServer`) on .NET 10.

This is a generated binding package. It exposes provider APIs to TypeScript and
Tsonic while your workspace references the real NuGet assemblies.

## Install

```bash
npm install @tsonic/efcore-sqlserver @tsonic/efcore @tsonic/dotnet @tsonic/core
```

## Use with Tsonic

```bash
tsonic add nuget Microsoft.EntityFrameworkCore.SqlServer <version> @tsonic/efcore-sqlserver
tsonic restore
```

## Imports

Provider APIs are exported from the generated `Microsoft.EntityFrameworkCore`
namespace facade:

```ts
import { SqlServerDbContextOptionsExtensions } from "@tsonic/efcore-sqlserver/Microsoft.EntityFrameworkCore.js";
```

Use EF Core base types from `@tsonic/efcore`:

```ts
import { DbContextOptionsBuilder } from "@tsonic/efcore/Microsoft.EntityFrameworkCore.js";
```

## UseSqlServer example

```ts
import { DbContextOptionsBuilder } from "@tsonic/efcore/Microsoft.EntityFrameworkCore.js";
import { SqlServerDbContextOptionsExtensions } from "@tsonic/efcore-sqlserver/Microsoft.EntityFrameworkCore.js";

const builder = new DbContextOptionsBuilder();
SqlServerDbContextOptionsExtensions.UseSqlServer(builder, "Server=.;Database=app;Trusted_Connection=True;");
const options = builder.Options;
```

## Package shape

The package contains generated namespace facades, ESM stubs, internal
declarations, extension buckets, and `bindings.json` compiler metadata. It uses
`@tsonic/efcore`, `@tsonic/microsoft-extensions`, `@tsonic/dotnet`, and
`@tsonic/core` as peer packages for shared CLR types.

Generated CLR object slots use TypeScript `unknown`; value-type constraints use
`NonNullable<unknown>`. Provider code that receives a broad CLR value should
narrow it through a proven API before member access.

## Versioning

This repo is versioned by .NET major:

- .NET 10 → npm: `@tsonic/efcore-sqlserver@10.x`

## Development

Regenerate from sibling checkouts:

```bash
npm install
./__build/scripts/generate.sh
```

The generation script requires .NET 10, `../dotnet-bindgen`, `../dotnet`,
`../microsoft-extensions`, and `../efcore`.

## License

MIT
