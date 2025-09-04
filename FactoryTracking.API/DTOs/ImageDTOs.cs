using System.ComponentModel.DataAnnotations;

namespace FactoryTracking.API.DTOs
{
    public class ImageUploadRequest
    {
        [Required]
        public IFormFileCollection Images { get; set; } = null!;
    }

    public class ImageUploadResponse
    {
        public string Message { get; set; } = string.Empty;
        public List<string> ImageUrls { get; set; } = new List<string>();
        public int UploadedCount { get; set; }
    }

    public class ImageUploadResult
    {
        public string FileName { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public long Size { get; set; }
        public string ContentType { get; set; } = string.Empty;
        public DateTime UploadedAt { get; set; }
    }

    public class DeleteImageRequest
    {
        [Required]
        public string FileName { get; set; } = string.Empty;
    }
}