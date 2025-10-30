import { BigInt } from "@graphprotocol/graph-ts"
import { PlanCreated } from "../generated/SubscriptionManagerV1/SubscriptionManagerV1"
import { Plan } from "../generated/schema"
import { SubscriptionPlan as PlanTemplate } from "../generated/templates"
import { SubscriptionPlan as PlanContract } from "../generated/templates/SubscriptionPlan/SubscriptionPlan"

export function handlePlanCreated(event: PlanCreated): void {
  let plan = new Plan(event.params.planAddress.toHexString())
  
  plan.creator = event.params.creator
  plan.txHash = event.transaction.hash
  plan.blockNumber = event.block.number
  plan.blockTimestamp = event.block.timestamp
  plan.token = event.params.token
  plan.price = event.params.price
  plan.duration = event.params.duration
  plan.subscriberCount = BigInt.fromI32(0)

  // To get the beneficiary, we need to call the newly created plan contract
  let planContract = PlanContract.bind(event.params.planAddress)
  plan.beneficiary = planContract.BENEFICIARY()

  plan.save()

  // Start tracking the new plan contract for Subscription events
  PlanTemplate.create(event.params.planAddress)
}
