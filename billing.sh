#!/bin/bash
billing=$(aws --profile default ce get-cost-and-usage)  # Get the AWS Billing Info
echo "Billing information:"                             # Print the Billing Information
echo "  Total cost: $billing.TotalCost"
echo "  Usage: $billing.Usage"
echo "  Costs by service:"
for service in "${billing.ResultsByTime.GroupsByDimension.Dimensions[0].Values[@]}"; do
  echo "    $service: $billing.ResultsByTime.GroupsByDimension.Metrics[0].Values['${service}']"
done
