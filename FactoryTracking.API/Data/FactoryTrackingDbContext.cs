using Microsoft.EntityFrameworkCore;
using FactoryTracking.API.Models;

namespace FactoryTracking.API.Data
{
    public class FactoryTrackingDbContext : DbContext
    {
        public FactoryTrackingDbContext(DbContextOptions<FactoryTrackingDbContext> options) : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        public DbSet<CheckPoint> CheckPoints { get; set; }
        public DbSet<CheckPointLog> CheckPointLogs { get; set; }
        public DbSet<StopCard> StopCards { get; set; }
        public DbSet<LoginLog> LoginLogs { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // User entity configuration
            modelBuilder.Entity<User>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.Email).IsUnique();
                entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
                entity.Property(e => e.PasswordHash).IsRequired().HasMaxLength(255);
                entity.Property(e => e.FullName).IsRequired().HasMaxLength(100);
                entity.Property(e => e.Role).HasConversion<int>();
            });

            // CheckPoint entity configuration
            modelBuilder.Entity<CheckPoint>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.HasIndex(e => e.QRCode).IsUnique();
                entity.Property(e => e.Name).IsRequired().HasMaxLength(100);
                entity.Property(e => e.QRCode).IsRequired().HasMaxLength(255);
                entity.Property(e => e.Location).HasMaxLength(255);
            });

            // CheckPointLog entity configuration
            modelBuilder.Entity<CheckPointLog>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Status).HasConversion<int>();
                entity.Property(e => e.Description).HasMaxLength(500);
                // SQLite will use TEXT type by default for string properties

                // Foreign key relationships
                entity.HasOne(e => e.User)
                    .WithMany(u => u.CheckPointLogs)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);

                entity.HasOne(e => e.CheckPoint)
                    .WithMany(c => c.CheckPointLogs)
                    .HasForeignKey(e => e.CheckPointId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // StopCard entity configuration
            modelBuilder.Entity<StopCard>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.Description).IsRequired().HasMaxLength(1000);
                // SQLite will use TEXT type by default for string properties

                // Foreign key relationship
                entity.HasOne(e => e.User)
                    .WithMany(u => u.StopCards)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // LoginLog entity configuration
            modelBuilder.Entity<LoginLog>(entity =>
            {
                entity.HasKey(e => e.Id);
                entity.Property(e => e.DeviceInfo).HasMaxLength(255);

                // Foreign key relationship
                entity.HasOne(e => e.User)
                    .WithMany(u => u.LoginLogs)
                    .HasForeignKey(e => e.UserId)
                    .OnDelete(DeleteBehavior.Restrict);
            });

            // Seed data
            SeedData(modelBuilder);
        }

        private void SeedData(ModelBuilder modelBuilder)
        {
            // Seed admin user
            var adminUserId = Guid.NewGuid();
            modelBuilder.Entity<User>().HasData(
                new User
                {
                    Id = adminUserId,
                    Email = "admin@factory.com",
                    PasswordHash = BCrypt.Net.BCrypt.HashPassword("Admin123!"),
                    Role = UserRole.Admin,
                    FullName = "System Administrator",
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                }
            );

            // Seed 5 sample checkpoints
            var checkpoints = new[]
            {
                new CheckPoint
                {
                    Id = Guid.NewGuid(),
                    Name = "Assembly Line A - Start",
                    QRCode = "QR_ASSEMBLY_A_START",
                    Location = "Building 1, Floor 1",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new CheckPoint
                {
                    Id = Guid.NewGuid(),
                    Name = "Quality Control Station",
                    QRCode = "QR_QUALITY_CONTROL",
                    Location = "Building 1, Floor 2",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new CheckPoint
                {
                    Id = Guid.NewGuid(),
                    Name = "Packaging Department",
                    QRCode = "QR_PACKAGING_DEPT",
                    Location = "Building 2, Floor 1",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new CheckPoint
                {
                    Id = Guid.NewGuid(),
                    Name = "Safety Equipment Check",
                    QRCode = "QR_SAFETY_EQUIPMENT",
                    Location = "Main Entrance",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new CheckPoint
                {
                    Id = Guid.NewGuid(),
                    Name = "Warehouse Exit",
                    QRCode = "QR_WAREHOUSE_EXIT",
                    Location = "Building 3, Loading Bay",
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            };

            modelBuilder.Entity<CheckPoint>().HasData(checkpoints);
        }
    }
}