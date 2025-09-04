using FactoryTracking.API.Models;

namespace FactoryTracking.API.DTOs
{
    public class CheckPointDto
    {
        public Guid Id { get; set; }
        public string Name { get; set; } = string.Empty;
        public string QRCode { get; set; } = string.Empty;
        public string? Location { get; set; }
        public bool IsActive { get; set; }
    }

    public class CheckPointScanRequest
    {
        public CheckPointStatus Status { get; set; }
        public string? Description { get; set; }
        public List<string>? ImageUrls { get; set; }
    }

    public class CheckPointLogDto
    {
        public Guid Id { get; set; }
        public string CheckPointName { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class AdminCheckPointLogDto
    {
        public Guid Id { get; set; }
        public string CheckPointName { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string UserEmail { get; set; } = string.Empty;
        public string Status { get; set; } = string.Empty;
        public string? Description { get; set; }
        public List<string> ImageUrls { get; set; } = new List<string>();
        public DateTime CreatedAt { get; set; }
    }

    public class AdminCheckPointLogsResponse
    {
        public List<AdminCheckPointLogDto> Logs { get; set; } = new List<AdminCheckPointLogDto>();
        public int TotalCount { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public int TotalPages { get; set; }
    }
}