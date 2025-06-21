using Microsoft.EntityFrameworkCore;

namespace ServiceB.Models; // Change to ServiceC.Models for Service C

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }
    public DbSet<User> Users => Set<User>();
}