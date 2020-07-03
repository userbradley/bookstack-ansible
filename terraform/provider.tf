provider "google" {
  project = "absolute-access-271419"
  region  = "us-central1"
  zone    = "us-central1-c"
  credentials = file("your-file-here.json")
 }
