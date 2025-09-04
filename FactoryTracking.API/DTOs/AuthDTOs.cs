using System.ComponentModel.DataAnnotations;
using FactoryTracking.API.Models;

namespace FactoryTracking.API.DTOs
{
    public class LoginRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;
        
        public string? DeviceInfo { get; set; }
    }

    public class LoginResponse
    {
        public string Token { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public UserInfo User { get; set; } = new UserInfo();
    }

    public class RegisterRequest
    {
        [Required]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6, ErrorMessage = "Password must be at least 6 characters long")]
        public string Password { get; set; } = string.Empty;

        [Required]
        public string FullName { get; set; } = string.Empty;

        [Required]
        public UserRole Role { get; set; }
    }

    public class RegisterResponse
    {
        public string Message { get; set; } = string.Empty;
        public UserInfo User { get; set; } = null!;
    }

    public class UserInfo
    {
        public Guid Id { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Role { get; set; } = string.Empty;
    }
}