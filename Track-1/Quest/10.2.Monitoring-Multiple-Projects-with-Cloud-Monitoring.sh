curl -o default.sh https://raw.githubusercontent.com/user9-21/GCRF/main/files/default.sh
source default.sh


secondproject 

gcloud compute instances create instance2 --project $SECOND_PROJECT_ID --zone=us-central1-a

completed "Task 1"

echo "${BOLD}${RED}
		Make sure that you are in Project 2($SECOND_PROJECT_ID) to proceed further in the lab ${RESET}"

echo "${BOLD}${MAGENTA}
Visit-${CYAN} https://console.cloud.google.com/monitoring/settings/add-projects?project=$SECOND_PROJECT_ID
${MAGENTA}
Select Project ID 1($PROJECT_ID). 

Under Select Scoping Project, select Use this project as the scoping project. 

Click ADD PROJECTS then click Confirm.
 ${RESET}"

sleep 60 
 
echo "${BOLD}${BLUE}
Visit-${CYAN} https://console.cloud.google.com/monitoring/groups/create?project=$SECOND_PROJECT_ID
${BLUE}

 Name :${CYAN} DemoGroup ${BLUE}
 
   Under Add criterion
   
		Type     :${CYAN} Name ${BLUE}
		Operator :${CYAN} Contains ${BLUE}
		Value    :${CYAN} instance ${BLUE}
		
		Click DONE, then click CREATE.

 ${RESET}"
sleep 60 
completed "Task 2"

echo "${BOLD}${YELLOW}
Visit-${CYAN} https://console.cloud.google.com/monitoring/uptime?project=$SECOND_PROJECT_ID ${YELLOW}

click +CREATE UPTIME CHECK.

 
   
		Title           :${CYAN} DemoGroup uptime check${YELLOW}, then click Next.
		Protocol        :${CYAN} TCP ${YELLOW}
		Resource Type   :${CYAN} instance ${YELLOW}
		Applies To      :${CYAN} Group${YELLOW},and then select ${CYAN}DemoGroup ${YELLOW}
		Port            :${CYAN} 22 ${YELLOW}
		Check frequency :${CYAN} 1 minute${YELLOW}, then click Next.
		
		Click Next again.

Put the slider in ${CYAN}off${YELLOW} state for Create an alert option in Alert & Notification section.

Click ${CYAN}TEST${YELLOW} to verify that your uptime check can connect to the resource.

When you see a ${GREEN}green${YELLOW} check mark everything can connect, click ${CYAN}CREATE${YELLOW}.

 ${RESET}"
sleep 70 
completed "Task 3"


echo "${BOLD}${BLUE}
Visit-${CYAN}https://console.cloud.google.com/monitoring/alerting/policies/create?project=$SECOND_PROJECT_ID
${BLUE}


In your New condition, click ${CYAN}SELECT A METRIC.${BLUE}

Turn off the Show only active resources & metrics toggle.

In the Select a metric field, search ${CYAN}check_passed${BLUE} and click ${CYAN}VM Instance > Uptime_check > Check passed${BLUE}. Click ${CYAN}Apply.${BLUE}

Click ${CYAN}ADD FILTER${BLUE}, set the Filter to ${CYAN}check_id${BLUE} and select ${CYAN}demogroup-uptime-check${BLUE} as the Value. Click ${CYAN}DONE${BLUE} and then ${CYAN}NEXT.${BLUE}

Select ${CYAN}Metric absence${BLUE} as ${CYAN}Condition type_ ${BLUE}and click NEXT.

Leave ${CYAN}Multi-condition trigger${BLUE} default and click ${CYAN}NEXT${BLUE}.

Turn off Configure notifications.

	  Alert policy  Name : ${CYAN}Uptime Check Policy${BLUE}
		

Click NEXT.

Click ${CYAN}CREATE POLICY${BLUE}.
 ${RESET}"
sleep 80 
completed "Task 4"

completed "Lab"

remove_files 