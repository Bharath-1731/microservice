using NLog.Web;
using Ocelot.DependencyInjection;
using Ocelot.Middleware;
using Prometheus;
var builder = WebApplication.CreateBuilder(args);

// NLog: Setup NLog for Dependency injection
builder.Logging.ClearProviders();
builder.Host.UseNLog();

// Ocelot config
builder.Configuration.AddJsonFile("ocelot.json", optional: false, reloadOnChange: true);
builder.Services.AddOcelot();

// Use SwaggerForOcelot instead of AddSwaggerGen
builder.Services.AddSwaggerForOcelot(builder.Configuration);

var app = builder.Build();
app.UseHttpMetrics();
// Use SwaggerForOcelot UI
app.UseSwaggerForOcelotUI(opt =>
{
    opt.PathToSwaggerGenerator = "/swagger/docs";
    //opt.DownstreamSwaggerEndPointBasePath = "swagger";
    // No RoutePrefix property available
});
app.MapMetrics("/metrics");
// Redirect root "/" to Swagger UI
//app.MapGet("/", context =>
//{
//    context.Response.Redirect("/swagger");
//    return Task.CompletedTask;
//});

app.UseRouting();
await app.UseOcelot();

app.Run();
