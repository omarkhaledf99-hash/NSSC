using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryTracking.API.Models
{
    public class User
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        [EmailAddress]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [StringLength(255)]
        public string PasswordHash { get; set; } = string.Empty;

        [Required]
        public UserRole Role { get; set; } = UserRole.NormalUser;

        [Required]
        [StringLength(100)]
        public string FullName { get; set; } = string.Empty;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        public bool IsActive { get; set; } = true;

        // Navigation properties
        public virtual ICollection<CheckPointLog> CheckPointLogs { get; set; } = new List<CheckPointLog>();
        public virtual ICollection<StopCard> StopCards { get; set; } = new List<StopCard>();
        public virtual ICollection<LoginLog> LoginLogs { get; set; } = new List<LoginLog>();
    }

    public enum UserRole
    {
        NormalUser = 0,
        Admin = 1
    }
}