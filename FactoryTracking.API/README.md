# Factory Tracking API

A .NET 8 Web API for factory worker tracking system with QR code checkpoints and stop card functionality.

## Prerequisites

- .NET 8 SDK
- SQL Server (LocalDB for development)
- Entity Framework Core Tools

## Setup Instructions

### 1. Install .NET 8 SDK
Download and install from: https://dotnet.microsoft.com/download/dotnet/8.0

### 2. Install Entity Framework Tools
```bash
dotnet tool install --global dotnet-ef
```

### 3. Restore NuGet Packages
```bash
dotnet restore
```

### 4. Create Database Migration
```bash
dotnet ef migrations add InitialCreate
```

### 5. Update Database
```bash
dotnet ef database update
```

### 6. Run the Application
```bash
dotnet run
```

## Project Structure

```
FactoryTracking.API/
├── Controllers/     # API Controllers
├── Models/         # Entity Models
├── Data/           # DbContext and Database Configuration
├── Services/       # Business Logic Services
├── DTOs/           # Data Transfer Objects
├── Middleware/     # Custom Middleware
└── Program.cs      # Application Entry Point
```

## Database Schema

### Tables
- **Users**: User accounts with roles (NormalUser, Admin)
- **CheckPoints**: QR code checkpoint locations
- **CheckPointLogs**: Worker checkpoint scan records
- **StopCards**: Safety issue reports
- **LoginLogs**: User login tracking

### Default Data
- Admin user: `admin@factory.com` / `Admin123!`
- 5 sample checkpoints with QR codes

## API Configuration

- **CORS**: Configured to allow Flutter app connections
- **Authentication**: JWT Bearer tokens
- **Database**: SQL Server with Entity Framework Core
- **Swagger**: Available in development mode

## Environment Configuration

- Development: Uses LocalDB with separate development database
- Production: Configure connection string in appsettings.json
- JWT settings configurable in appsettings.json

## Next Steps

1. Install .NET 8 SDK
2. Run migration commands to create database
3. Implement API controllers for authentication and business logic
4. Add service layer for business operations
5. Create DTOs for API request/response models