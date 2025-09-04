using System.ComponentModel.DataAnnotations;
using FactoryTracking.API.Models;

namespace FactoryTracking.API.DTOs
{
    public class CreateStopCardRequest
    {
        [Required]
        public string Title { get; set; } = string.Empty;

        [Required]
        public string Description { get; set; } = string.Empty;

        [Required]
        public StopCardPriority Priority { get; set; }

        public List<string>? ImageUrls { get; set; }
    }

    public class StopCardDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Priority { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class StopCardDetailDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Priority { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public List<string> ImageUrls { get; set; } = new List<string>();
        public DateTime CreatedAt { get; set; }
    }

    public class AdminStopCardDto
    {
        public Guid Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string Description { get; set; } = string.Empty;
        public string Priority { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public List<string> ImageUrls { get; set; } = new List<string>();
        public DateTime CreatedAt { get; set; }
        public DateTime? UpdatedAt { get; set; }
    }

    public class AdminStopCardsResponse
    {
        public List<AdminStopCardDto> StopCards { get; set; } = new List<AdminStopCardDto>();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
    }
}