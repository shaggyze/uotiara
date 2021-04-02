using HyddwnLauncher.Http;
using Swebs;
using Swebs.RequestHandlers.CSharp;

public class CaptchaController : Controller
{
    public override void Handle(HttpRequestEventArgs args, string requestPath, string localPath)
    {
        var token = args.Request.QueryString["t"];

        args.Response.StatusCode = 200;
        args.Response.Send("200");

        WebServer.Instance.CompletedAction(token);
    }
}
