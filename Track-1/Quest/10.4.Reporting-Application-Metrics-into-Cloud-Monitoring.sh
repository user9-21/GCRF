curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh

export ZONE=us-central1-a
#export BUCKET_NAME=$(gcloud info --format='value(config.project)')
#gsutil mb gs://$BUCKET_NAME/

cat > ssh.sh <<EOF
curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh
sudo curl -O https://storage.googleapis.com/golang/go1.16.2.linux-amd64.tar.gz
sudo tar -xvf go1.16.2.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo mv go /usr/local
sudo apt-get update
sudo apt-get install git -y
export PATH=$PATH:/usr/local/go/bin
go get go.opencensus.io
go get contrib.go.opencensus.io/exporter/stackdriver
go mod init test3
go mod tidy
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
sudo bash add-google-cloud-ops-agent-repo.sh --also-install
sudo apt-get update

completed "Task 2"
echo '
package main
import (
        "fmt"
        "math/rand"
        "time"
)
func main() {
        // Heres our fake video processing application. Every second, it
        // checks the length of the input queue (e.g., number of videos
        // waiting to be processed) and records that information.
        for {
                time.Sleep(1 * time.Second)
                queueSize := getQueueSize()
                // Record the queue size.
                fmt.Println("Queue size: ", queueSize)
        }
}
func getQueueSize() (int64) {
        // Fake out a queue size here by returning a random number between
        // 1 and 100.
        return rand.Int63n(100) + 1
}' > main.go
go run main.go

echo '
package main
import (
    "context"
    "fmt"
    "log"
    "math/rand"
    "os"
    "time"
    "contrib.go.opencensus.io/exporter/stackdriver" 
    "go.opencensus.io/stats"
    "go.opencensus.io/stats/view"
    monitoredrespb "google.golang.org/genproto/googleapis/api/monitoredres"
)
var videoServiceInputQueueSize = stats.Int64(
    "my.videoservice.org/measure/input_queue_size",
    "Number of videos queued up in the input queue",
    stats.UnitDimensionless)
func main() {
    exporter, err := stackdriver.NewExporter(stackdriver.Options {
        ProjectID: os.Getenv("MY_PROJECT_ID"),
        Resource: & monitoredrespb.MonitoredResource {
            Type: "gce_instance",
            Labels: map[string] string {
                "instance_id": os.Getenv("MY_GCE_INSTANCE_ID"),
                "zone": os.Getenv("MY_GCE_INSTANCE_ZONE"),
            },
        },
    })
    if err != nil {
        log.Fatalf("Cannot setup Stackdriver exporter: %v", err)
    }
    view.RegisterExporter(exporter)
       
    ctx := context.Background()
    if err := view.Register( & view.View {
        Name: "my.videoservice.org/measure/input_queue_size",
        Description: "Number of videos queued up in the input queue",
        Measure: videoServiceInputQueueSize,
        Aggregation: view.LastValue(),
    });
    err != nil {
            log.Fatalf("Cannot setup view: %v", err)
        }
        // Set the reporting period to be once per second.
    view.SetReportingPeriod(1 * time.Second)
    // Heres our fake video processing application. Every second, it
    // checks the length of the input queue (e.g., number of videos
    // waiting to be processed) and records that information.
    for {
        time.Sleep(1 * time.Second)
        queueSize := getQueueSize()
        // Record the queue size.
        stats.Record(ctx, videoServiceInputQueueSize.M(queueSize))
        fmt.Println("Queue size: ", queueSize)
    }
}
func getQueueSize()(int64) {
    // Fake out a queue size here by returning a random number between
    // 1 and 100.
    return rand.Int63n(100) + 1
}' > main.go
export MY_PROJECT_ID=$PROJECT_ID
export MY_GCE_INSTANCE_ID=my-opencensus-demo
export MY_GCE_INSTANCE_ZONE=us-central1-a
go mod tidy

echo "${CYAN}${BOLD}https://console.cloud.google.com/monitoring/metrics-explorer?project=$PROJECT_ID$
${YELLOW}
if opencensus doesn't appear in metric
start typing '${CYAN}input${YELLOW}' and select any kubernetes metric to view monitoring 

{RESET}"

go run main.go

completed "Task 3"

remove_files

exit
logout
exit
EOF

#gsutil  cp ssh.sh gs://$BUCKET_NAME
#startup-script-url=gs://$BUCKET_NAME/ssh.sh,
gcloud compute instances create my-opencensus-demo --zone=us-central1-a --machine-type=n1-standard-1 --network-interface=network-tier=PREMIUM,subnet=default --metadata=enable-oslogin=true --maintenance-policy=MIGRATE --provisioning-model=STANDARD --scopes=https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_only --tags=http-server,https-server --create-disk=auto-delete=yes,boot=yes,device-name=my-opencensus-demo,image=projects/debian-cloud/global/images/debian-10-buster-v20220621,mode=rw,size=10,type=projects/$PROJECT_ID/zones/us-central1-a/diskTypes/pd-balanced --no-shielded-secure-boot --shielded-vtpm --shielded-integrity-monitoring --reservation-affinity=any
completed "Task 1"

gcloud compute instances list

STATUS=$(gcloud compute instances describe my-opencensus-demo --zone=us-central1-a --format="value(status)")

echo "${CYAN}${BOLD}https://console.cloud.google.com/monitoring?project=$PROJECT_ID${RESET}"

while [ $STATUS != 'RUNNING' ];
do sleep 10 && STATUS=$(gcloud compute instances describe my-opencensus-demo --zone=us-central1-a --format="value(status)") && echo $STATUS;
done
echo "${GREEN}${BOLD}$STATUS${RESET}"
completed "Task 2"


gcloud compute scp --zone=us-central1-a --quiet ssh.sh my-opencensus-demo:~
echo "${BOLD}${YELLOW}
Run this in ssh:
${BG_RED}
source ssh.sh
${RESET}"

gcloud compute scp --zone=us-central1-a --quiet ssh.sh my-opencensus-demo:~
gcloud compute ssh my-opencensus-demo --zone=us-central1-a --quiet

completed "Task 3"

completed "Lab"

remove_files 