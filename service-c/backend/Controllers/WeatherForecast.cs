using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ServiceC.Models;
using System.Collections.Generic;
using System;

namespace ServiceC.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    [HttpGet]
    public IEnumerable<WeatherForecast> Get()
    {
        return new List<WeatherForecast>
        {
            new WeatherForecast(DateOnly.FromDateTime(DateTime.Now), 25, "Sunny"),
            new WeatherForecast(DateOnly.FromDateTime(DateTime.Now.AddDays(1)), 28, "Cloudy"),
            new WeatherForecast(DateOnly.FromDateTime(DateTime.Now.AddDays(2)), 22,"Rainy")
        };
    }
}
