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
 * Posts Directory
 */

resource "aws_s3_bucket_object" "1-14-18-html-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/1-14-18-html.png"
  source = "assets/posts/1-14-18-html.png"
  etag = "${md5(file("assets/posts/1-14-18-html.png"))}"
}

resource "aws_s3_bucket_object" "1-14-18-webresult-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/1-14-18-webresult.png"
  source = "assets/posts/1-14-18-webresult.png"
  etag = "${md5(file("assets/posts/1-14-18-webresult.png"))}"
}

resource "aws_s3_bucket_object" "1-27-17-postlazy-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/1-27-17-postlazy.png"
  source = "assets/posts/1-27-17-postlazy.png"
  etag = "${md5(file("assets/posts/1-27-17-postlazy.png"))}"
}

resource "aws_s3_bucket_object" "1-27-17-prelazy-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/1-27-17-prelazy.png"
  source = "assets/posts/1-27-17-prelazy.png"
  etag = "${md5(file("assets/posts/1-27-17-prelazy.png"))}"
}

resource "aws_s3_bucket_object" "5-20-18-blockchain-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/5-20-18-blockchain.png"
  source = "assets/posts/5-20-18-blockchain.png"
  etag = "${md5(file("assets/posts/5-20-18-blockchain.png"))}"
}

resource "aws_s3_bucket_object" "5-20-18-simpleblock-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/5-20-18-simpleblock.png"
  source = "assets/posts/5-20-18-simpleblock.png"
  etag = "${md5(file("assets/posts/5-20-18-simpleblock.png"))}"
}

resource "aws_s3_bucket_object" "5-20-18-exercise-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/5-20-18-exercise.png"
  source = "assets/posts/5-20-18-exercise.png"
  etag = "${md5(file("assets/posts/5-20-18-exercise.png"))}"
}

resource "aws_s3_bucket_object" "5-31-18-seed-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/5-31-18-seed.png"
  source = "assets/posts/5-31-18-seed.png"
  etag = "${md5(file("assets/posts/5-31-18-seed.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-array-chain-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-9-18-array-chain.png"
  source = "assets/posts/6-9-18-array-chain.png"
  etag = "${md5(file("assets/posts/6-9-18-array-chain.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-function-chain-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-9-18-function-chain.png"
  source = "assets/posts/6-9-18-function-chain.png"
  etag = "${md5(file("assets/posts/6-9-18-function-chain.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-object-chain-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-9-18-object-chain.png"
  source = "assets/posts/6-9-18-object-chain.png"
  etag = "${md5(file("assets/posts/6-9-18-object-chain.png"))}"
}

resource "aws_s3_bucket_object" "6-9-18-prototype-traverse-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-9-18-prototype-traverse.png"
  source = "assets/posts/6-9-18-prototype-traverse.png"
  etag = "${md5(file("assets/posts/6-9-18-prototype-traverse.png"))}"
}

resource "aws_s3_bucket_object" "6-13-18-network-files-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-13-18-network-files.png"
  source = "assets/posts/6-13-18-network-files.png"
  etag = "${md5(file("assets/posts/6-13-18-network-files.png"))}"
}

resource "aws_s3_bucket_object" "6-13-18-writing-notes-gif" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-13-18-writing-notes.gif"
  source = "assets/posts/6-13-18-writing-notes.gif"
  etag = "${md5(file("assets/posts/6-13-18-writing-notes.gif"))}"
}

resource "aws_s3_bucket_object" "6-18-18-grid-0-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-18-18-grid-0.png"
  source = "assets/posts/6-18-18-grid-0.png"
  etag = "${md5(file("assets/posts/6-18-18-grid-0.png"))}"
}

resource "aws_s3_bucket_object" "6-18-18-grid-1-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-18-18-grid-1.png"
  source = "assets/posts/6-18-18-grid-1.png"
  etag = "${md5(file("assets/posts/6-18-18-grid-1.png"))}"
}

resource "aws_s3_bucket_object" "6-18-18-grid-2-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/6-18-18-grid-2.png"
  source = "assets/posts/6-18-18-grid-2.png"
  etag = "${md5(file("assets/posts/6-18-18-grid-2.png"))}"
}

resource "aws_s3_bucket_object" "7-4-18-groovy-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/7-4-18-groovy-strict-type-check.png"
  source = "assets/posts/7-4-18-groovy-strict-type-check.png"
  etag = "${md5(file("assets/posts/7-4-18-groovy-strict-type-check.png"))}"
}

resource "aws_s3_bucket_object" "8-5-18-graphql-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/8-5-18-graphql.png"
  source = "assets/posts/8-5-18-graphql.png"
  etag = "${md5(file("assets/posts/8-5-18-graphql.png"))}"
}

resource "aws_s3_bucket_object" "8-8-18-graphiql-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/8-8-18-graphiql.png"
  source = "assets/posts/8-8-18-graphiql.png"
  etag = "${md5(file("assets/posts/8-8-18-graphiql.png"))}"
}

resource "aws_s3_bucket_object" "8-5-18-restapi-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/8-5-18-restapi.png"
  source = "assets/posts/8-5-18-restapi.png"
  etag = "${md5(file("assets/posts/8-5-18-restapi.png"))}"
}

resource "aws_s3_bucket_object" "9-3-18-aws-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/9-3-18-aws.png"
  source = "assets/posts/9-3-18-aws.png"
  etag = "${md5(file("assets/posts/9-3-18-aws.png"))}"
}

resource "aws_s3_bucket_object" "9-3-18-web-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/9-3-18-web.png"
  source = "assets/posts/9-3-18-web.png"
  etag = "${md5(file("assets/posts/9-3-18-web.png"))}"
}

resource "aws_s3_bucket_object" "9-7-18-serverless-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/9-7-18-serverless.png"
  source = "assets/posts/9-7-18-serverless.png"
  etag = "${md5(file("assets/posts/9-7-18-serverless.png"))}"
}

resource "aws_s3_bucket_object" "11-6-17-graph-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/11-6-17-FairfieldGraphImage.png"
  source = "assets/posts/11-6-17-FairfieldGraphImage.png"
  etag = "${md5(file("assets/posts/11-6-17-FairfieldGraphImage.png"))}"
}

resource "aws_s3_bucket_object" "11-13-17-prompt-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/11-13-17-prompt.png"
  source = "assets/posts/11-13-17-prompt.png"
  etag = "${md5(file("assets/posts/11-13-17-prompt.png"))}"
}

resource "aws_s3_bucket_object" "11-21-17-results-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/11-21-17-results.png"
  source = "assets/posts/11-21-17-results.png"
  etag = "${md5(file("assets/posts/11-21-17-results.png"))}"
}

resource "aws_s3_bucket_object" "11-26-17-results-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/11-26-17-results.png"
  source = "assets/posts/11-26-17-results.png"
  etag = "${md5(file("assets/posts/11-26-17-results.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-mongodb-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/12-30-17-mongodb.png"
  source = "assets/posts/12-30-17-mongodb.png"
  etag = "${md5(file("assets/posts/12-30-17-mongodb.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-restapi-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/12-30-17-restapi.png"
  source = "assets/posts/12-30-17-restapi.png"
  etag = "${md5(file("assets/posts/12-30-17-restapi.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-xmlresponse-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/12-30-17-xmlresponse.png"
  source = "assets/posts/12-30-17-xmlresponse.png"
  etag = "${md5(file("assets/posts/12-30-17-xmlresponse.png"))}"
}

resource "aws_s3_bucket_object" "12-30-17-xmlresponsetext-png" {
  bucket = "${aws_s3_bucket.asset-jarombek.id}"
  key = "posts/12-30-17-xmlresponsetext.png"
  source = "assets/posts/12-30-17-xmlresponsetext.png"
  etag = "${md5(file("assets/posts/12-30-17-xmlresponsetext.png"))}"
}

/*
 * Logos Directory
 */