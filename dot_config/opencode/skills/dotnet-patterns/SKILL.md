---
name: dotnet-patterns
description: .NET / C# production patterns — architecture, EF Core, Minimal APIs, validation, testing, and idiomatic C# conventions
license: MIT
---

# .NET Patterns

Production-grade .NET patterns for building maintainable, performant
services and APIs.

## Architecture patterns

### Vertical slice vs Horizontal layers

```
❌ Horizontal:            ✅ Vertical:
Controllers/              Features/
  BookingsController.cs     Bookings/
Services/                     CreateBooking/
  BookingService.cs            CreateBookingEndpoint.cs
Repositories/                  CreateBookingHandler.cs
  BookingRepository.cs         BookingCreatedEvent.cs
Models/                      Booking.cs
  Booking.cs                 BookingsDbContext.cs
```

### Result pattern

```csharp
public sealed record Result<T>
{
    public T? Value { get; }
    public Error? Error { get; }
    public bool IsSuccess => Error is null;

    public static Result<T> Success(T value) => new() { Value = value };
    public static Result<T> Failure(Error error) => new() { Error = error };
}

public sealed record Error(string Code, string Message);
```

### Minimal API endpoint pattern

```csharp
public static class CreateBookingEndpoint
{
    public static void Map(IEndpointRouteBuilder app)
    {
        app.MapPost("/api/bookings", Handle)
            .WithName("CreateBooking")
            .WithOpenApi();
    }

    private static async Task<Results<Created<BookingResponse>, ValidationProblem>> Handle(
        CreateBookingRequest request,
        IBookingService service,
        CancellationToken ct)
    {
        var result = await service.CreateAsync(request, ct);
        return result.IsSuccess
            ? TypedResults.Created($"/api/bookings/{result.Value.Id}", result.Value)
            : TypedResults.ValidationProblem(result.Error.ToDictionary());
    }
}
```

## EF Core patterns

```csharp
// DbContext per bounded context
public class BookingsDbContext : DbContext
{
    public DbSet<Booking> Bookings => Set<Booking>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Booking>(entity =>
        {
            entity.ToTable("bookings");
            entity.HasKey(e => e.Id);
            entity.Property(e => e.Status).HasConversion<string>().HasMaxLength(50);
            entity.HasIndex(e => e.Status);
        });
    }
}

// AsNoTracking for reads
public async Task<Booking?> GetByIdAsync(Guid id, CancellationToken ct)
{
    return await _db.Bookings
        .AsNoTracking()
        .Include(b => b.Lines)
        .FirstOrDefaultAsync(b => b.Id == id, ct);
}
```

## FluentValidation patterns

```csharp
public sealed class CreateBookingValidator : AbstractValidator<CreateBookingRequest>
{
    public CreateBookingValidator()
    {
        RuleFor(x => x.CustomerId).NotEmpty();
        RuleFor(x => x.Lines).NotEmpty();
        RuleForEach(x => x.Lines).SetValidator(new BookingLineValidator());
    }
}

public sealed class BookingLineValidator : AbstractValidator<BookingLineRequest>
{
    public BookingLineValidator()
    {
        RuleFor(x => x.ProductId).NotEmpty();
        RuleFor(x => x.Quantity).GreaterThan(0);
    }
}
```

## Testing patterns

```csharp
// Integration test with WebApplicationFactory + TestContainers
public class CreateBookingTests : IClassFixture<IntegrationTestFactory>
{
    private readonly IntegrationTestFactory _factory;

    [Fact]
    public async Task CreateBooking_WithValidRequest_ReturnsCreated()
    {
        var client = _factory.CreateClient();
        var request = new CreateBookingRequest(/* ... */);

        var response = await client.PostAsJsonAsync("/api/bookings", request);

        response.StatusCode.Should().Be(HttpStatusCode.Created);
    }
}
```

## Anti-patterns

- ❌ `Task.Run()` in ASP.NET Core — use async I/O natively
- ❌ Synchronous `.Result` or `.Wait()` — causes deadlocks
- ❌ Giant `DbContext` with 50+ DbSets — split by bounded context
- ❌ `throw Exception` for validation — use Result pattern
- ❌ `[ApiController]` implicit binding — be explicit with `[FromBody]`
- ❌ String concatenation for SQL — use parameterized queries
- ❌ `AsEnumerable()` before `Where()` — unfiltered query

## See also

- [rest-api-design](../rest-api-design/SKILL.md)
- [database-patterns](../database-patterns/SKILL.md)
- [addyosmani/agent-skills: api-and-interface-design](../.agents/skills/api-and-interface-design/SKILL.md)
