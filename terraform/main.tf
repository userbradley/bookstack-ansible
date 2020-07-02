resource "google_compute_instance" "bookstack_instance1" {
  name         = "bookstack-1"
  machine_type = "e2-micro" 
  scheduling {
   preemptible= "true" 
   automatic_restart= "false"   
}
  boot_disk {
    initialize_params {
      image = var.bootdisk
    }
  }
   network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }
    metadata = {
  ssh-keys = "stannardb:${file("id_rsa.pub")}"
}
}