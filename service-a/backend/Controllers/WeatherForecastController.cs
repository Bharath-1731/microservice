using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ServiceA.Models;
using System.Collections.Generic;
using System;

namespace ServiceA.Controllers;

[ApiController]
[Route("[controller]")]
//[Authorize]
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
