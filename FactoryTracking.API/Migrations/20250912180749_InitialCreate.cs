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
                    { new Guid("0fce2f25-da54-475b-a6b3-cbab5dfd9679"), new DateTime(2025, 9, 12, 18, 7, 49, 527, DateTimeKind.Utc).AddTicks(4270), true, "Building 1, Floor 2", "Quality Control Station", "QR_QUALITY_CONTROL" },
                    { new Guid("2732ffe4-0d6a-47c0-a67f-afd49ae7eda4"), new DateTime(2025, 9, 12, 18, 7, 49, 527, DateTimeKind.Utc).AddTicks(4270), true, "Building 1, Floor 1", "Assembly Line A - Start", "QR_ASSEMBLY_A_START" },
                    { new Guid("4463e280-c432-4d1d-8b99-99a8573cc46c"), new DateTime(2025, 9, 12, 18, 7, 49, 527, DateTimeKind.Utc).AddTicks(4280), true, "Building 2, Floor 1", "Packaging Department", "QR_PACKAGING_DEPT" },
                    { new Guid("4469f8b0-43b6-4748-a1df-773701ca6c86"), new DateTime(2025, 9, 12, 18, 7, 49, 527, DateTimeKind.Utc).AddTicks(4300), true, "Building 3, Loading Bay", "Warehouse Exit", "QR_WAREHOUSE_EXIT" },
                    { new Guid("a503a7a9-0eef-4a4f-9a91-0f2e03593d2a"), new DateTime(2025, 9, 12, 18, 7, 49, 527, DateTimeKind.Utc).AddTicks(4280), true, "Main Entrance", "Safety Equipment Check", "QR_SAFETY_EQUIPMENT" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "Id", "CreatedAt", "Email", "FullName", "IsActive", "PasswordHash", "Role" },
                values: new object[,]
                {
                    { new Guid("36ee7105-8498-458b-af27-0f47bbf5deb4"), new DateTime(2025, 9, 12, 18, 7, 49, 394, DateTimeKind.Utc).AddTicks(3580), "admin@factory.com", "System Administrator", true, "$2a$11$FlCuKAoCmM5nLEKEt9d5z.65TglR6hNryD9Tkz8RfZXVOp2WU5pXe", 1 },
                    { new Guid("bd5c0530-057f-493a-966e-4cb8c07ee671"), new DateTime(2025, 9, 12, 18, 7, 49, 527, DateTimeKind.Utc).AddTicks(3930), "user@factory.com", "Test User", true, "$2a$11$dbkf4YcA18mrny/1vh/0FuBqRTBr93b0F1fRMJaCYsVPOnT1yyh1S", 0 }
                });

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
