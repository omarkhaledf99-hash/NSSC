using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Text.RegularExpressions;
using FactoryTracking.API.Data;
using FactoryTracking.API.Models;

namespace FactoryTracking.API.Services
{
    public class AuthService : IAuthService
    {
        private readonly FactoryTrackingDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly ILogger<AuthService> _logger;

        public AuthService(FactoryTrackingDbContext context, IConfiguration configuration, ILogger<AuthService> logger)
        {
            _context = context;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task<User?> ValidateUserAsync(string email, string password)
        {
            try
            {
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Email == email && u.IsActive);

                if (user == null || !BCrypt.Net.BCrypt.Verify(password, user.PasswordHash))
                {
                    return null;
                }

                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating user with email: {Email}", email);
                return null;
            }
        }

        public async Task<User> CreateUserAsync(string email, string password, string fullName, UserRole role)
                {
            try
            {
                if (!ValidatePassword(password))
                {
                    throw new ArgumentException("Password does not meet requirements");
                }

                // Check if user already exists
                var existingUser = await _context.Users
                    .FirstOrDefaultAsync(u => u.Email == email);

                if (existingUser != null)
                {
                    throw new InvalidOperationException("User with this email already exists");
                }

                var user = new User
                {
                    Email = email,
                    PasswordHash = HashPassword(password),
                    FullName = fullName,
                    Role = role,
                    CreatedAt = DateTime.UtcNow,
                    IsActive = true
                };

                _context.Users.Add(user);
                await _context.SaveChangesAsync();

                return user;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating user with email: {Email}", email);
                throw;
            }
        }

        public string GenerateJwtToken(User user)
        {
            try
            {
                var jwtSettings = _configuration.GetSection("JwtSettings");
                var secretKey = jwtSettings["SecretKey"] ?? "YourSuperSecretKeyThatIsAtLeast32CharactersLong!";
                var key = Encoding.ASCII.GetBytes(secretKey);

                var tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(new[]
                    {
                        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
                        new Claim(ClaimTypes.Email, user.Email),
                        new Claim(ClaimTypes.Name, user.FullName),
                        new Claim(ClaimTypes.Role, user.Role.ToString())
                    }),
                    Expires = DateTime.UtcNow.AddMinutes(int.Parse(jwtSettings["ExpirationInMinutes"] ?? "60")),
                    Issuer = jwtSettings["Issuer"],
                    Audience = jwtSettings["Audience"],
                    SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
                };

                var tokenHandler = new JwtSecurityTokenHandler();
                var token = tokenHandler.CreateToken(tokenDescriptor);
                return tokenHandler.WriteToken(token);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error generating JWT token for user: {UserId}", user.Id);
                throw;
            }
        }

        public async Task LogLoginAsync(Guid userId, string? deviceInfo)
        {
            try
            {
                var loginLog = new LoginLog
                {
                    UserId = userId,
                    LoginTime = DateTime.UtcNow,
                    DeviceInfo = deviceInfo
                };

                _context.LoginLogs.Add(loginLog);
                await _context.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error logging login for user: {UserId}", userId);
                // Don't throw here as login logging failure shouldn't prevent login
            }
        }

        public bool ValidatePassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                return false;

            // Minimum 6 characters requirement
            if (password.Length < 6)
                return false;

            // Additional password strength requirements (optional)
            // At least one letter and one number
            var hasLetter = Regex.IsMatch(password, @"[a-zA-Z]");
            var hasNumber = Regex.IsMatch(password, @"\d");

            return hasLetter && hasNumber;
        }

        public string HashPassword(string password)
        {
            return BCrypt.Net.BCrypt.HashPassword(password);
        }
    }
}