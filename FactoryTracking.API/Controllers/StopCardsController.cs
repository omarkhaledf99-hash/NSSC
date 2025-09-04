using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;
using System.ComponentModel.DataAnnotations;
using FactoryTracking.API.Data;
using FactoryTracking.API.Models;
using FactoryTracking.API.DTOs;

namespace FactoryTracking.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class StopCardsController : ControllerBase
    {
        private readonly FactoryTrackingDbContext _context;
        private readonly ILogger<StopCardsController> _logger;

        public StopCardsController(FactoryTrackingDbContext context, ILogger<StopCardsController> logger)
        {
            _context = context;
            _logger = logger;
        }

        [HttpPost]
        public async Task<IActionResult> CreateStopCard([FromBody] CreateStopCardRequest request)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!Guid.TryParse(userIdClaim, out var userId))
                {
                    return Unauthorized(new { message = "Invalid user token" });
                }

                if (string.IsNullOrWhiteSpace(request.Description))
                {
                    return BadRequest(new { message = "Description is required" });
                }

                var stopCard = new StopCard
                {
                    UserId = userId,
                    Description = request.Description.Trim(),
                    ImageUrls = request.ImageUrls != null && request.ImageUrls.Any()
                        ? System.Text.Json.JsonSerializer.Serialize(request.ImageUrls)
                        : null,
                    CreatedAt = DateTime.UtcNow
                };

                _context.StopCards.Add(stopCard);
                await _context.SaveChangesAsync();

                return Ok(new { message = "Stop card created successfully", stopCardId = stopCard.Id });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating stop card for user: {UserId}", User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
                return StatusCode(500, new { message = "An error occurred while creating the stop card" });
            }
        }

        [HttpGet]
        public async Task<IActionResult> GetStopCards([FromQuery] int page = 1, [FromQuery] int pageSize = 20)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!Guid.TryParse(userIdClaim, out var userId))
                {
                    return Unauthorized(new { message = "Invalid user token" });
                }

                var stopCards = await _context.StopCards
                    .Where(sc => sc.UserId == userId)
                    .OrderByDescending(sc => sc.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(sc => new StopCardDto
                    {
                        Id = sc.Id,
                        Description = sc.Description,
                        HasImages = !string.IsNullOrEmpty(sc.ImageUrls),
                        CreatedAt = sc.CreatedAt
                    })
                    .ToListAsync();

                return Ok(stopCards);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving stop cards for user: {UserId}", User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
                return StatusCode(500, new { message = "An error occurred while retrieving stop cards" });
            }
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetStopCard(Guid id)
        {
            try
            {
                var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
                if (!Guid.TryParse(userIdClaim, out var userId))
                {
                    return Unauthorized(new { message = "Invalid user token" });
                }

                var stopCard = await _context.StopCards
                    .Where(sc => sc.Id == id && sc.UserId == userId)
                    .Select(sc => new StopCardDetailDto
                    {
                        Id = sc.Id,
                        Description = sc.Description,
                        ImageUrls = !string.IsNullOrEmpty(sc.ImageUrls) 
                            ? System.Text.Json.JsonSerializer.Deserialize<List<string>>(sc.ImageUrls) ?? new List<string>()
                            : new List<string>(),
                        CreatedAt = sc.CreatedAt
                    })
                    .FirstOrDefaultAsync();

                if (stopCard == null)
                {
                    return NotFound(new { message = "Stop card not found" });
                }

                return Ok(stopCard);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving stop card {StopCardId} for user: {UserId}", id, User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
                return StatusCode(500, new { message = "An error occurred while retrieving the stop card" });
            }
        }

        [HttpGet("all")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetAllStopCards(
            [FromQuery] int page = 1, 
            [FromQuery] int pageSize = 20,
            [FromQuery] DateTime? fromDate = null,
            [FromQuery] DateTime? toDate = null,
            [FromQuery] Guid? userId = null,
            [FromQuery] StopCardStatus? status = null,
            [FromQuery] StopCardPriority? priority = null)
        {
            try
            {
                var query = _context.StopCards
                    .Include(sc => sc.User)
                    .AsQueryable();

                // Apply date filters
                if (fromDate.HasValue)
                {
                    query = query.Where(sc => sc.CreatedAt >= fromDate.Value);
                }

                if (toDate.HasValue)
                {
                    query = query.Where(sc => sc.CreatedAt <= toDate.Value.AddDays(1));
                }

                // Apply user filter
                if (userId.HasValue)
                {
                    query = query.Where(sc => sc.UserId == userId.Value);
                }

                // Apply status filter
                if (status.HasValue)
                {
                    query = query.Where(sc => sc.Status == status.Value);
                }

                // Apply priority filter
                if (priority.HasValue)
                {
                    query = query.Where(sc => sc.Priority == priority.Value);
                }

                var totalCount = await query.CountAsync();
                var totalPages = (int)Math.Ceiling((double)totalCount / pageSize);

                var stopCards = await query
                    .OrderByDescending(sc => sc.CreatedAt)
                    .Skip((page - 1) * pageSize)
                    .Take(pageSize)
                    .Select(sc => new AdminStopCardDto
                    {
                        Id = sc.Id,
                        Title = sc.Title,
                        Description = sc.Description,
                        Priority = sc.Priority.ToString(),
                        Status = sc.Status.ToString(),
                        UserName = sc.User.FullName,
                        UserEmail = sc.User.Email,
                        ImageUrls = !string.IsNullOrEmpty(sc.ImageUrls) 
                            ? System.Text.Json.JsonSerializer.Deserialize<List<string>>(sc.ImageUrls) ?? new List<string>()
                            : new List<string>(),
                        CreatedAt = sc.CreatedAt,
                        UpdatedAt = sc.UpdatedAt
                    })
                    .ToListAsync();

                return Ok(new AdminStopCardsResponse
                {
                    StopCards = stopCards,
                    TotalCount = totalCount,
                    Page = page,
                    PageSize = pageSize,
                    TotalPages = totalPages
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving all stop cards for admin");
                return StatusCode(500, new { message = "An error occurred while retrieving stop cards" });
            }
        }
    }


}