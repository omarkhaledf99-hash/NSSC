using System.ComponentModel.DataAnnotations;

namespace FactoryTracking.API.Models
{
    public class CheckPoint
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        [StringLength(100)]
        public string Name { get; set; } = string.Empty;

        [Required]
        [StringLength(255)]
        public string QRCode { get; set; } = string.Empty;

        [StringLength(255)]
        public string? Location { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<CheckPointLog> CheckPointLogs { get; set; } = new List<CheckPointLog>();
    }
}