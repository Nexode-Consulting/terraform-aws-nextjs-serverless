import json

def load_pages_manifest():
    with open("pages-manifest.json", "r") as f:
        pages_manifest = json.loads(f.read())
    return pages_manifest

pages_manifest = load_pages_manifest()

def lambda_handler(event, context):
    request = event["Records"][0]["cf"]["request"]

    s3_bucket_domain = request["origin"]["custom"]["customHeaders"]["server-assets-bucket-domain"][0]["value"]

    if request["uri"] in pages_manifest:
        if pages_manifest[request["uri"]].endswith(".html"):
            
            # Replace the default origin with the S3 bucket
            request["headers"]["host"][0]["value"] = s3_bucket_domain
            request["origin"]["custom"]["domainName"] = s3_bucket_domain

            request["origin"]["custom"]["protocol"] = "http"
            request["origin"]["custom"]["port"] = 80
            request["origin"]["custom"]["authMethod"] = "none"
            
            request["uri"] = "/" + pages_manifest[request["uri"]]
            
            request["headers"]["cache-control"] = [
                {
                    "key" : "Cache-Control",
                    "value" : "public, max-age=600"
                }
            ]
            
            request["origin"]["custom"]["customHeaders"] = {}

    print(request)
    return request