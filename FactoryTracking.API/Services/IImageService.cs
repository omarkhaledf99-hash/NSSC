namespace FactoryTracking.API.Services
{
    public interface IImageService
    {
        Task<List<ImageUploadResult>> UploadImagesAsync(IFormFileCollection images);
        Task<bool> DeleteImageAsync(string fileName);
        Task<Stream?> GetImageAsync(string fileName);
        Task<string> GetImageUrlAsync(string fileName);
    }

    public class ImageUploadResult
    {
        public string FileName { get; set; } = string.Empty;
        public string Url { get; set; } = string.Empty;
        public long Size { get; set; }
        public bool IsCompressed { get; set; }
    }
}