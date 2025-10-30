import { BigInt } from "@graphprotocol/graph-ts"
import { Subscribed, SubscriptionPaused } from "../generated/templates/SubscriptionPlan/SubscriptionPlan"
import { Subscription, Plan } from "../generated/schema"

export function handleSubscribed(event: Subscribed): void {
  let planId = event.address.toHexString()
  let userId = event.params.user.toHexString()
  let subscriptionId = userId + "-" + planId

  let subscription = Subscription.load(subscriptionId)
  let plan = Plan.load(planId)

  if (plan == null) {
    // This should not happen if manager-mapping is correct
    return
  }

  if (subscription == null) {
    // This is a new subscription, increment lifetime counter
    subscription = new Subscription(subscriptionId)
    plan.subscriberCount = plan.subscriberCount.plus(BigInt.fromI32(1))
  }
  
  subscription.user = event.params.user
  subscription.plan = planId
  subscription.expiry = event.params.expiry
  subscription.active = true
  subscription.createdAt = event.block.timestamp
  subscription.txHash = event.transaction.hash
  
  subscription.save()
  plan.save()
}

export function handleSubscriptionPaused(event: SubscriptionPaused): void {
  let planId = event.address.toHexString()
  let userId = event.params.user.toHexString()
  let subscriptionId = userId + "-" + planId
  
  let subscription = Subscription.load(subscriptionId)
  if (subscription != null) {
    subscription.active = false
    subscription.save()
  }
}
