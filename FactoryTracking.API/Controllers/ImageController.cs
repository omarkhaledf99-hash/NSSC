using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.ComponentModel.DataAnnotations;
using FactoryTracking.API.Services;
using FactoryTracking.API.DTOs;

namespace FactoryTracking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ImageController : ControllerBase
    {
        private readonly IImageService _imageService;
        private readonly ILogger<ImageController> _logger;

        public ImageController(IImageService imageService, ILogger<ImageController> logger)
        {
            _imageService = imageService;
            _logger = logger;
        }

        [HttpPost("upload")]
        public async Task<IActionResult> UploadImages([FromForm] ImageUploadRequest request)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(ModelState);
                }

                if (request.Images == null || !request.Images.Any())
                {
                    return BadRequest(new { message = "No images provided" });
                }

                if (request.Images.Count > 5)
                {
                    return BadRequest(new { message = "Maximum 5 images allowed per request" });
                }

                var validationResult = ValidateImages(request.Images);
                if (!validationResult.IsValid)
                {
                    return BadRequest(new { message = validationResult.ErrorMessage });
                }

                var uploadResults = await _imageService.UploadImagesAsync(request.Images);

                return Ok(new ImageUploadResponse
                {
                    Message = "Images uploaded successfully",
                    ImageUrls = uploadResults.Select(r => r.Url).ToList(),
                    UploadedCount = uploadResults.Count
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error uploading images");
                return StatusCode(500, new { message = "An error occurred while uploading images" });
            }
        }

        [HttpDelete("{fileName}")]
        public async Task<IActionResult> DeleteImage(string fileName)
        {
            try
            {
                if (string.IsNullOrEmpty(fileName))
                {
                    return BadRequest(new { message = "File name is required" });
                }

                var result = await _imageService.DeleteImageAsync(fileName);
                if (!result)
                {
                    return NotFound(new { message = "Image not found" });
                }

                return Ok(new { message = "Image deleted successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error deleting image: {FileName}", fileName);
                return StatusCode(500, new { message = "An error occurred while deleting the image" });
            }
        }

        [HttpGet("{fileName}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetImage(string fileName)
        {
            try
            {
                if (string.IsNullOrEmpty(fileName))
                {
                    return BadRequest(new { message = "File name is required" });
                }

                var imageStream = await _imageService.GetImageAsync(fileName);
                if (imageStream == null)
                {
                    return NotFound(new { message = "Image not found" });
                }

                var contentType = GetContentType(fileName);
                return File(imageStream, contentType);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving image: {FileName}", fileName);
                return StatusCode(500, new { message = "An error occurred while retrieving the image" });
            }
        }

        private ImageValidationResult ValidateImages(IFormFileCollection images)
        {
            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png" };
            const long maxFileSize = 3 * 1024 * 1024; // 3MB

            foreach (var image in images)
            {
                if (image.Length == 0)
                {
                    return new ImageValidationResult { IsValid = false, ErrorMessage = "Empty file detected" };
                }

                if (image.Length > maxFileSize)
                {
                    return new ImageValidationResult { IsValid = false, ErrorMessage = $"File {image.FileName} exceeds maximum size of 3MB" };
                }

                var extension = Path.GetExtension(image.FileName).ToLowerInvariant();
                if (!allowedExtensions.Contains(extension))
                {
                    return new ImageValidationResult { IsValid = false, ErrorMessage = $"File {image.FileName} has invalid extension. Only jpg, jpeg, png are allowed" };
                }

                // Validate that it's actually an image by checking content type
                if (!image.ContentType.StartsWith("image/"))
                {
                    return new ImageValidationResult { IsValid = false, ErrorMessage = $"File {image.FileName} is not a valid image" };
                }
            }

            return new ImageValidationResult { IsValid = true };
        }

        private string GetContentType(string fileName)
        {
            var extension = Path.GetExtension(fileName).ToLowerInvariant();
            return extension switch
            {
                ".jpg" or ".jpeg" => "image/jpeg",
                ".png" => "image/png",
                _ => "application/octet-stream"
            };
        }
    }

    public class ImageValidationResult
    {
        public bool IsValid { get; set; }
        public string ErrorMessage { get; set; } = string.Empty;
    }
}