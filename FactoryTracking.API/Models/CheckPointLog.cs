using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FactoryTracking.API.Models
{
    public class CheckPointLog
    {
        [Key]
        public Guid Id { get; set; } = Guid.NewGuid();

        [Required]
        public Guid UserId { get; set; }

        [Required]
        public Guid CheckPointId { get; set; }

        [Required]
        public CheckPointStatus Status { get; set; }

        [StringLength(500)]
        public string? Description { get; set; }

        [Column(TypeName = "nvarchar(max)")]
        public string? ImageUrls { get; set; } // JSON array of image URLs

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        [ForeignKey("UserId")]
        public virtual User User { get; set; } = null!;

        [ForeignKey("CheckPointId")]
        public virtual CheckPoint CheckPoint { get; set; } = null!;
    }

    public enum CheckPointStatus
    {
        Good = 0,
        Issue = 1
    }
}