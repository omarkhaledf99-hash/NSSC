using FactoryTracking.API.Models;

namespace FactoryTracking.API.Services
{
    public interface IAuthService
    {
        Task<User?> ValidateUserAsync(string email, string password);
        Task<User> CreateUserAsync(string email, string password, string fullName, UserRole role);
        string GenerateJwtToken(User user);
        Task LogLoginAsync(Guid userId, string? deviceInfo);
        bool ValidatePassword(string password);
        string HashPassword(string password);
    }
}