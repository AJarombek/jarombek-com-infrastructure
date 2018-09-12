/*
 * Configure an S3 bucket
 * Author: Andrew Jarombek
 * Date: 9/12/2018
 */

resource "aws_s3_bucket" "asset-jarombek" {
  bucket = "asset-jarombek"
  acl = "public-read"
  policy = "${file("policy.json")}"

  tags {
    Name = "asset.jarombek.com"
  }

  website {
    index_document = "jarombek.png"
    error_document = "jarombek.png"
  }

  cors_rule {
    allowed_origins = ["https://jarombek.com"]
    allowed_methods = ["POST", "PUT", "DELETE", "HEAD"]
    allowed_headers = ["*"]
  }

  cors_rule {
    allowed_origins = ["*"]
    allowed_methods = ["GET"]
    allowed_headers = ["*"]
  }
}

resource "aws_s3_bucket" "www-asset-jarombek" {
  bucket = "www-asset-jarombek"
  acl = "public-read"
  policy = "${file("www-policy.json")}"

  tags {
    Name = "www.asset.jarombek.com"
  }

  website {
    redirect_all_requests_to = "https://asset.jarombek.com"
  }
}

/*
 * S3 Bucket Contents
 */

/*
 * Root Directory
 */

resource "aws_s3_bucket_object" "jarombek-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "jarombek.png"
  source = "assets/jarombek.png"
  etag = "${md5(file("assets/jarombek.png"))}"
}

resource "aws_s3_bucket_object" "blizzard-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "blizzard.png"
  source = "assets/blizzard.png"
  etag = "${md5(file("assets/blizzard.png"))}"
}

resource "aws_s3_bucket_object" "bulk-insert-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "bulk-insert.png"
  source = "assets/bulk-insert.png"
  etag = "${md5(file("assets/bulk-insert.png"))}"
}

resource "aws_s3_bucket_object" "common-user-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "common-user.png"
  source = "assets/common-user.png"
  etag = "${md5(file("assets/common-user.png"))}"
}

resource "aws_s3_bucket_object" "computer-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "computer.png"
  source = "assets/computer.png"
  etag = "${md5(file("assets/computer.png"))}"
}

resource "aws_s3_bucket_object" "database-er-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "Database-ER.png"
  source = "assets/Database-ER.png"
  etag = "${md5(file("assets/Datebase-ER.png"))}"
}

resource "aws_s3_bucket_object" "diamond-uml-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "diamond-uml.png"
  source = "assets/diamond-uml.png"
  etag = "${md5(file("assets/diamond-uml.png"))}"
}

resource "aws_s3_bucket_object" "dynamic-jsx-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "dynamic-jsx.png"
  source = "assets/dynamic-jsx.png"
  etag = "${md5(file("assets/dynamic-jsx.png"))}"
}

resource "aws_s3_bucket_object" "error-message-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "error-message.png"
  source = "assets/error-message.png"
  etag = "${md5(file("assets/error-message.png"))}"
}

resource "aws_s3_bucket_object" "jarombek-home-background-jpg" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "jarombek-home-background.jpg"
  source = "assets/jarombek-home-background.jpg"
  etag = "${md5(file("assets/jarombek-home-background.jpg"))}"
}

resource "aws_s3_bucket_object" "mean-stack-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "MEAN-Stack.png"
  source = "assets/MEAN-Stack.png"
  etag = "${md5(file("assets/MEAN-Stack.png"))}"
}

resource "aws_s3_bucket_object" "kayak-jpg" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "kayak.jpg"
  source = "assets/kayak.jpg"
  etag = "${md5(file("assets/kayak.jpg"))}"
}

resource "aws_s3_bucket_object" "login-component-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "login-component.png"
  source = "assets/login-component.png"
  etag = "${md5(file("assets/login-component.png"))}"
}

resource "aws_s3_bucket_object" "main-component-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "main-component.png"
  source = "assets/main-component.png"
  etag = "${md5(file("assets/main-component.png"))}"
}

resource "aws_s3_bucket_object" "meowcat-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "meowcat.png"
  source = "assets/meowcat.png"
  etag = "${md5(file("assets/meowcat.png"))}"
}

resource "aws_s3_bucket_object" "search-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "search.png"
  source = "assets/search.png"
  etag = "${md5(file("assets/search.png"))}"
}

resource "aws_s3_bucket_object" "signup-component-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "signup-component.png"
  source = "assets/signup-component.png"
  etag = "${md5(file("assets/signup-component.png"))}"
}

resource "aws_s3_bucket_object" "triangles-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "triangles.png"
  source = "assets/triangles.png"
  etag = "${md5(file("assets/triangles.png"))}"
}

/*
 * Fonts Directory
 */

resource "aws_s3_bucket_object" "dyslexie-bold-ttf" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "fonts/dyslexie-bold.ttf"
  source = "assets/fonts/dyslexie-bold.ttf"
  etag = "${md5(file("assets/fonts/dyslexie-bold.ttf"))}"
}

resource "aws_s3_bucket_object" "fantasque-sans-mono-bold-ttf" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "fonts/FantasqueSansMono-Bold.ttf"
  source = "assets/fonts/FantasqueSansMono-Bold.ttf"
  etag = "${md5(file("assets/fonts/FantasqueSansMono-Bold.ttf"))}"
}

resource "aws_s3_bucket_object" "longway-regular-otf" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "fonts/Longway-Regular.otf"
  source = "assets/fonts/Longway-Regular.otf"
  etag = "${md5(file("assets/fonts/Longway-Regular.otf"))}"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-ttf" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "fonts/SylexiadSansThin.ttf"
  source = "assets/fonts/SylexiadSansThin.ttf"
  etag = "${md5(file("assets/fonts/SylexiadSansThin.ttf"))}"
}

resource "aws_s3_bucket_object" "sylexiad-sans-thin-bold-ttf" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "fonts/SylexiadSansThin-Bold.ttf"
  source = "assets/fonts/SylexiadSansThin-Bold.ttf"
  etag = "${md5(file("assets/fonts/SylexiadSansThin-Bold.ttf"))}"
}

/*
 * Logos Directory
 */

/*
 * Posts Directory
 */