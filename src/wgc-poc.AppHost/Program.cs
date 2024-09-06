var builder = DistributedApplication.CreateBuilder(args);

builder.AddProject<Projects.myApp>("myapp");

builder.AddProject<Projects.myApi>("myapi");

builder.Build().Run();
