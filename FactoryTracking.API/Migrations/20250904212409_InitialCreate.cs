using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace FactoryTracking.API.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CheckPoints",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Name = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    QRCode = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    Location = table.Column<string>(type: "TEXT", maxLength: 255, nullable: true),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CheckPoints", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    Email = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    PasswordHash = table.Column<string>(type: "TEXT", maxLength: 255, nullable: false),
                    Role = table.Column<int>(type: "INTEGER", nullable: false),
                    FullName = table.Column<string>(type: "TEXT", maxLength: 100, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    IsActive = table.Column<bool>(type: "INTEGER", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "CheckPointLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    CheckPointId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 500, nullable: true),
                    ImageUrls = table.Column<string>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CheckPointLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CheckPointLogs_CheckPoints_CheckPointId",
                        column: x => x.CheckPointId,
                        principalTable: "CheckPoints",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CheckPointLogs_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "LoginLogs",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    LoginTime = table.Column<DateTime>(type: "TEXT", nullable: false),
                    DeviceInfo = table.Column<string>(type: "TEXT", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_LoginLogs", x => x.Id);
                    table.ForeignKey(
                        name: "FK_LoginLogs_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "StopCards",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "TEXT", nullable: false),
                    UserId = table.Column<Guid>(type: "TEXT", nullable: false),
                    Title = table.Column<string>(type: "TEXT", maxLength: 200, nullable: false),
                    Description = table.Column<string>(type: "TEXT", maxLength: 1000, nullable: false),
                    Status = table.Column<int>(type: "INTEGER", nullable: false),
                    Priority = table.Column<int>(type: "INTEGER", nullable: false),
                    ImageUrls = table.Column<string>(type: "TEXT", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "TEXT", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "TEXT", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_StopCards", x => x.Id);
                    table.ForeignKey(
                        name: "FK_StopCards_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "CheckPoints",
                columns: new[] { "Id", "CreatedAt", "IsActive", "Location", "Name", "QRCode" },
                values: new object[,]
                {
                    { new Guid("37ecfb59-c8c6-4a80-a12a-c1abf2aacfb6"), new DateTime(2025, 9, 4, 21, 24, 9, 528, DateTimeKind.Utc).AddTicks(2290), true, "Building 1, Floor 1", "Assembly Line A - Start", "QR_ASSEMBLY_A_START" },
                    { new Guid("46d369e1-6383-43f2-949f-0f5ea7014c42"), new DateTime(2025, 9, 4, 21, 24, 9, 528, DateTimeKind.Utc).AddTicks(2320), true, "Building 3, Loading Bay", "Warehouse Exit", "QR_WAREHOUSE_EXIT" },
                    { new Guid("4efe5eab-e14e-45d9-8573-4d26edc4736d"), new DateTime(2025, 9, 4, 21, 24, 9, 528, DateTimeKind.Utc).AddTicks(2300), true, "Building 1, Floor 2", "Quality Control Station", "QR_QUALITY_CONTROL" },
                    { new Guid("901368bb-1299-43da-9ecf-d2a115deb100"), new DateTime(2025, 9, 4, 21, 24, 9, 528, DateTimeKind.Utc).AddTicks(2300), true, "Building 2, Floor 1", "Packaging Department", "QR_PACKAGING_DEPT" },
                    { new Guid("bc32af2c-af51-4b4b-8626-51aab56b3c41"), new DateTime(2025, 9, 4, 21, 24, 9, 528, DateTimeKind.Utc).AddTicks(2310), true, "Main Entrance", "Safety Equipment Check", "QR_SAFETY_EQUIPMENT" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "Email", "FullName", "IsActive", "PasswordHash", "Role" },
                values: new object[] { new Guid("a876fd5d-3513-45ab-8349-1b4fff7574d5"), new DateTime(2025, 9, 4, 21, 24, 9, 528, DateTimeKind.Utc).AddTicks(2160), "admin@factory.com", "System Administrator", true, "$2a$11$eAAikS85ytbTfd8YRIoFI.sQaSzCEJgsHclzMS4KG7kK/Y/6F4YBu", 1 });

            migrationBuilder.CreateIndex(
                name: "IX_CheckPointLogs_CheckPointId",
                table: "CheckPointLogs",
                column: "CheckPointId");

            migrationBuilder.CreateIndex(
                name: "IX_CheckPointLogs_UserId",
                table: "CheckPointLogs",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_CheckPoints_QRCode",
                table: "CheckPoints",
                column: "QRCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_LoginLogs_UserId",
                table: "LoginLogs",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_StopCards_UserId",
                table: "StopCards",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_Users_Email",
                table: "Users",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CheckPointLogs");

            migrationBuilder.DropTable(
                name: "LoginLogs");

            migrationBuilder.DropTable(
                name: "StopCards");

            migrationBuilder.DropTable(
                name: "CheckPoints");

            migrationBuilder.DropTable(
                name: "Users");
        }
    }
}
