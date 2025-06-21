using System.ComponentModel.DataAnnotations;

namespace ServiceB.Models; // Change to ServiceC.Models for Service C

public class LoginRequest
{
    [Required]
    public string Username { get; set; } = string.Empty;

    [Required]
    public string Password { get; set; } = string.Empty;
}