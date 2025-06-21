namespace ServiceB.Models; // Change to ServiceC.Models for Service C
using System;
using System.Collections.Generic;
public record WeatherForecast(DateOnly Date, int TemperatureC, string? Summary)
{
    public int TemperatureF => 32 + (int)(TemperatureC / 0.5556);
}