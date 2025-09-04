using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using FactoryTracking.API.Data;
using FactoryTracking.API.Models;
using FactoryTracking.API.DTOs;

namespace FactoryTracking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CheckPointsController : ControllerBase
    {
        private readonly FactoryTrackingDbContext _context;
        private readonly ILogger<CheckPointsController> _logger;

        public CheckPointsController(FactoryTrackingDbContext context, ILogger<CheckPointsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpGet]
        public async Task<IActionResult> GetCheckPoints()
        {
            try
            {
                var checkPoints = await _context.CheckPoints
                    .Where(cp => cp.IsActive)
                    .OrderBy(cp => cp.Name)
                    .Select(cp => new CheckPointDto
                    {
                        Id = cp.Id,
                        Name = cp.Name,
                        QRCode = cp.QRCode,
                        Location = cp.Location,
                        IsActive = cp.IsActive
                    })
                    .ToListAsync();

                return Ok(checkPoints);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving checkpoints");
                return StatusCode(500, new { message = "An error occurred while retrieving checkpoints" });
            }
        }

        [HttpGet("{qrCode}")]
        public async Task<IActionResult> GetCheckPointByQRCode(string qrCode)
        {
            try
            {
                var checkPoint = await _context.CheckPoints
                    .Where(cp => cp.QRCode == qrCode && cp.IsActive)
                    .Select(cp => new CheckPointDto
                    {
                        Id = cp.Id,
                        Name = cp.Name,
                        QRCode = cp.QRCode,
                        Location = cp.Location,
                        IsActive = cp.IsActive
                    })
                    .FirstOrDefaultAsync();

                if (checkPoint == null)
                {
                    return NotFound(new { message = "Checkpoint not found" });
                }

                return Ok(checkPoint);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving checkpoint by QR code: {QRCode}", qrCode);
                return StatusCode(500, new { message = "An error occurred while retrieving the checkpoint" });
            }
        }

        [HttpPost("{id}/scan")]
        public async Task<IActionResult> ScanCheckPoint(Guid id, [FromBody] CheckPointScanRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!Guid.TryParse(userIdClaim, out var userId))
                {
                    return Unauthorized(new { message = "Invalid user token" });
                }

                // Verify checkpoint exists
                var checkPoint = await _context.CheckPoints
                    .FirstOrDefaultAsync(cp => cp.Id == id && cp.IsActive);

                if (checkPoint == null)
                {
                    return BadRequest(new { message = "Invalid checkpoint" });
                }

                // Create checkpoint log
                var checkPointLog = new CheckPointLog
                {
                    UserId = userId,
                    CheckPointId = id,
                    Status = request.Status,
                    Description = request.Description,
                    ImageUrls = request.ImageUrls != null && request.ImageUrls.Any() 
                        ? System.Text.Json.JsonSerializer.Serialize(request.ImageUrls) 
                        : null,
                    CreatedAt = DateTime.UtcNow
                };

                _context.CheckPointLogs.Add(checkPointLog);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Checkpoint logged successfully", logId = checkPointLog.Id });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error logging checkpoint for user: {UserId}", User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
                return StatusCode(500, new { message = "An error occurred while logging the checkpoint" });
            }
        }

        [HttpGet("logs")]
        public async Task<IActionResult> GetCheckPointLogs([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!Guid.TryParse(userIdClaim, out var userId))
                {
                    return Unauthorized(new { message = "Invalid user token" });
                }

                var logs = await _context.CheckPointLogs
                    .Where(log => log.UserId == userId)
                    .Include(log => log.CheckPoint)
                    .OrderByDescending(log => log.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(log => new CheckPointLogDto
                    {
                        Id = log.Id,
                        CheckPointName = log.CheckPoint.Name,
                        Status = log.Status.ToString(),
                        Description = log.Description,
                        CreatedAt = log.CreatedAt
                    })
                    .ToListAsync();

                return Ok(logs);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving checkpoint logs for user: {UserId}", User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
                return StatusCode(500, new { message = "An error occurred while retrieving checkpoint logs" });
            }
        }

        [HttpGet("logs/all")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAllCheckPointLogs(
            [FromQuery] int page = 1, 
            [FromQuery] int pageSize = 20,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] Guid? userId = null,
            [FromQuery] Guid? checkPointId = null)
        {
            try
            {
                var query = _context.CheckPointLogs
                    .Include(log => log.CheckPoint)
                    .Include(log => log.User)
                    .AsQueryable();

                // Apply date filters
                if (fromDate.HasValue)
                {
                    query = query.Where(log => log.CreatedAt >= fromDate.Value);
                }

                if (toDate.HasValue)
                {
                    query = query.Where(log => log.CreatedAt <= toDate.Value.AddDays(1));
                }

                // Apply user filter
                if (userId.HasValue)
                {
                    query = query.Where(log => log.UserId == userId.Value);
                }

                // Apply checkpoint filter
                if (checkPointId.HasValue)
                {
                    query = query.Where(log => log.CheckPointId == checkPointId.Value);
                }

                var totalCount = await query.CountAsync();
                var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

                var logs = await query
                    .OrderByDescending(log => log.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(log => new AdminCheckPointLogDto
                    {
                        Id = log.Id,
                        CheckPointName = log.CheckPoint.Name,
                        UserName = log.User.FullName,
                        UserEmail = log.User.Email,
                        Status = log.Status.ToString(),
                        Description = log.Description,
                        ImageUrls = new List<string>(),
                        CreatedAt = log.CreatedAt
                    })
                    .ToListAsync();

                return Ok(new AdminCheckPointLogsResponse
                {
                    Logs = logs,
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize,
                    TotalPages = totalPages
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all checkpoint logs");
                return StatusCode(500, new { message = "An error occurred while retrieving checkpoint logs" });
            }
        }
    }


}