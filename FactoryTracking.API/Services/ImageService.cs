using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Formats.Jpeg;

namespace FactoryTracking.API.Services
{
    public class ImageService : IImageService
    {
        private readonly BlobServiceClient _blobServiceClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<ImageService> _logger;
        private readonly string _containerName;

        public ImageService(BlobServiceClient blobServiceClient, IConfiguration configuration, ILogger<ImageService> logger)
        {
            _blobServiceClient = blobServiceClient;
            _configuration = configuration;
            _logger = logger;
            _containerName = _configuration["AzureStorage:ContainerName"] ?? "factory-images";
        }

        public async Task<List<ImageUploadResult>> UploadImagesAsync(IFormFileCollection images)
        {
            var results = new List<ImageUploadResult>();
            var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);

            // Ensure container exists
            await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

            foreach (var image in images)
            {
                try
                {
                    var fileName = GenerateUniqueFileName(image.FileName);
                    var blobClient = containerClient.GetBlobClient(fileName);

                    // Compress image if needed
                    var (compressedStream, isCompressed) = await CompressImageAsync(image);
                    
                    var blobHttpHeaders = new BlobHttpHeaders
                    {
                        ContentType = image.ContentType
                    };

                    await blobClient.UploadAsync(compressedStream, blobHttpHeaders);

                    results.Add(new ImageUploadResult
                    {
                        FileName = fileName,
                        Url = blobClient.Uri.ToString(),
                        Size = compressedStream.Length,
                        IsCompressed = isCompressed
                    });

                    compressedStream.Dispose();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error uploading image: {FileName}", image.FileName);
                    throw;
                }
            }

            return results;
        }

        public async Task<bool> DeleteImageAsync(string fileName)
        {
            try
            {
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                var blobClient = containerClient.GetBlobClient(fileName);

                var response = await blobClient.DeleteIfExistsAsync();
                return response.Value;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting image: {FileName}", fileName);
                return false;
            }
        }

        public async Task<Stream?> GetImageAsync(string fileName)
        {
            try
            {
                var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
                var blobClient = containerClient.GetBlobClient(fileName);

                if (!await blobClient.ExistsAsync())
                {
                    return null;
                }

                var response = await blobClient.DownloadStreamingAsync();
                return response.Value.Content;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving image: {FileName}", fileName);
                return null;
            }
        }

        public async Task<string> GetImageUrlAsync(string fileName)
        {
            var containerClient = _blobServiceClient.GetBlobContainerClient(_containerName);
            var blobClient = containerClient.GetBlobClient(fileName);

            if (await blobClient.ExistsAsync())
            {
                return blobClient.Uri.ToString();
            }

            return string.Empty;
        }

        private async Task<(Stream stream, bool isCompressed)> CompressImageAsync(IFormFile image)
        {
            const long maxSizeBeforeCompression = 1 * 1024 * 1024; // 1MB
            const int maxWidth = 1920;
            const int maxHeight = 1080;
            const int jpegQuality = 85;

            if (image.Length <= maxSizeBeforeCompression)
            {
                // No compression needed, return original
                var originalStream = new MemoryStream();
                await image.CopyToAsync(originalStream);
                originalStream.Position = 0;
                return (originalStream, false);
            }

            try
            {
                using var inputStream = image.OpenReadStream();
                using var imageSharp = await Image.LoadAsync(inputStream);

                // Resize if too large
                if (imageSharp.Width > maxWidth || imageSharp.Height > maxHeight)
                {
                    var resizeOptions = new ResizeOptions
                    {
                        Size = new Size(maxWidth, maxHeight),
                        Mode = ResizeMode.Max
                    };
                    imageSharp.Mutate(x => x.Resize(resizeOptions));
                }

                var outputStream = new MemoryStream();
                var encoder = new JpegEncoder { Quality = jpegQuality };
                await imageSharp.SaveAsync(outputStream, encoder);
                outputStream.Position = 0;

                return (outputStream, true);
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to compress image {FileName}, using original", image.FileName);
                
                // Fallback to original if compression fails
                var fallbackStream = new MemoryStream();
                await image.CopyToAsync(fallbackStream);
                fallbackStream.Position = 0;
                return (fallbackStream, false);
            }
        }

        private string GenerateUniqueFileName(string originalFileName)
        {
            var extension = Path.GetExtension(originalFileName);
            var uniqueId = Guid.NewGuid().ToString("N");
            var timestamp = DateTime.UtcNow.ToString("yyyyMMdd");
            return $"{timestamp}_{uniqueId}{extension}";
        }
    }
}