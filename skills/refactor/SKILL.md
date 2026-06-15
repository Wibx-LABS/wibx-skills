---
name: refactor
description: Improve code structure and readability without changing external behavior. Use when code is hard to maintain, functions are too large, code smells need addressing, or adding features is difficult. Triggered by "clean up this code", "refactor this", "improve this", or any structural improvement request on existing code.
license: Complete terms in LICENSE.txt
---

# Refactor

Behavior preserved. Small steps. Tests required. One thing at a time.

## When NOT to Refactor

- Code that works and won't change again
- Critical production code without tests (add tests first)
- Under tight deadline
- "Just because" — need a clear purpose

---

## Process

### 1. PREPARE
- Ensure tests exist (write them if missing)
- Commit current state
- Understand what the code does before touching it

### 2. IDENTIFY
- Find the specific code smell
- Plan the change before executing

### 3. REFACTOR (small steps)
- One small change at a time
- Run tests after each change
- Commit if tests pass

### 4. VERIFY
- All tests pass
- Behavior unchanged
- Performance unchanged or improved

---

## Code Smells & Fixes

### Long Method/Function
Break into focused, single-purpose functions. Target: <50 lines per function.

```ts
// BAD: 200-line function doing everything
async function processOrder(orderId) { /* all logic here */ }

// GOOD: Orchestrator delegates to focused functions
async function processOrder(orderId) {
  const order = await fetchOrder(orderId);
  validateOrder(order);
  const pricing = calculatePricing(order);
  await updateInventory(order);
  const shipment = await createShipment(order);
  await sendNotifications(order, pricing, shipment);
  return { order, pricing, shipment };
}
```

### Duplicated Code
Extract common logic into a shared function.

```ts
// BAD: Same logic repeated
function getMembershipDiscountRate(membership) {
  const rates = { gold: 0.2, silver: 0.1 };
  return rates[membership] || 0;
}
```

### Large Class / God Object
Single responsibility per class.

```ts
// BAD: UserManager with 50+ methods
// GOOD: Split by domain
class UserService   { create() {} update() {} delete() {} }
class EmailService  { send() {} }
class ReportService { generate() {} }
class PaymentService { process() {} }
```

### Long Parameter List
Group related parameters into an object.

```ts
// BAD
function createUser(email, password, name, age, address, city, country, phone) {}

// GOOD
function createUser(data: UserData) {}
```

### Magic Numbers/Strings
Replace with named constants.

```ts
// BAD
if (user.status === 2) {}
setTimeout(callback, 86400000);

// GOOD
const UserStatus = { ACTIVE: 1, INACTIVE: 2, SUSPENDED: 3 } as const;
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
if (user.status === UserStatus.INACTIVE) {}
setTimeout(callback, ONE_DAY_MS);
```

### Nested Conditionals (Arrow Code)
Use guard clauses / early returns.

```ts
// BAD: deeply nested
function process(order) {
  if (order) {
    if (order.user) {
      if (order.user.isActive) {
        // ...
      }
    }
  }
}

// GOOD: early returns
function process(order) {
  if (!order)            return { error: 'No order' };
  if (!order.user)       return { error: 'No user' };
  if (!order.user.isActive) return { error: 'User inactive' };
  if (order.total <= 0)  return { error: 'Invalid total' };
  return processOrder(order);
}
```

### Dead Code
Delete it. Git history has it if needed.

```ts
// Remove: unused functions, commented-out code, unused imports, unused variables
```

### Feature Envy
Move logic to the object that owns the data.

```ts
// BAD: Order reaches into User internals
class Order {
  calculateDiscount(user) {
    if (user.membershipLevel === 'gold') return this.total * 0.2;
  }
}

// GOOD: User owns membership logic
class User {
  getDiscountRate() {
    if (this.membershipLevel === 'gold') return 0.2;
    return 0;
  }
}
class Order {
  calculateDiscount(user) { return this.total * user.getDiscountRate(); }
}
```

### Primitive Obsession
Use domain types.

```ts
// BAD: raw strings for domain concepts
sendEmail('user@example.com', ...)

// GOOD: domain type with validation
class Email {
  private constructor(public readonly value: string) {
    if (!Email.isValid(value)) throw new Error('Invalid email');
  }
  static create(value: string) { return new Email(value); }
  static isValid(email: string) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email); }
}
```

### Inappropriate Intimacy
Ask, don't reach.

```ts
// BAD: reaching deep into another object
order.user.profile.address.street;

// GOOD: ask for what you need
order.getShippingAddress();
```

---

## Introducing Type Safety

```ts
// Before: untyped, fragile
function calculateDiscount(user, total, membership, date) { /* ... */ }

// After: typed, self-documenting
type Membership = 'bronze' | 'silver' | 'gold';

interface DiscountResult {
  original: number;
  discount: number;
  final: number;
  rate: number;
}

function calculateDiscount(user: User, total: number, date = new Date()): DiscountResult {
  if (total < 0) throw new Error('Total cannot be negative');
  // ...
}
```

---

## Design Patterns

### Strategy Pattern (replace conditionals)

```ts
// BAD: if/else chains for behavior variants
// GOOD: strategy per variant
interface ShippingStrategy { calculate(order: Order): number; }
class StandardShipping implements ShippingStrategy { calculate(o) { return o.total > 50 ? 0 : 5.99; } }
class ExpressShipping  implements ShippingStrategy { calculate(o) { return o.total > 100 ? 9.99 : 14.99; } }
class OvernightShipping implements ShippingStrategy { calculate(o) { return 29.99; } }

function calculateShipping(order: Order, strategy: ShippingStrategy) {
  return strategy.calculate(order);
}
```

### Guard Clauses (replace nested conditionals)
Already covered above. Prefer this over any pattern for simple validation.

---

## Checklist

**Code Quality**
- [ ] Functions < 50 lines
- [ ] Each function does one thing
- [ ] No duplicated logic
- [ ] Descriptive names (variables, functions, classes)
- [ ] No magic numbers/strings
- [ ] Dead code removed

**Structure**
- [ ] Related code is co-located
- [ ] Clear module boundaries
- [ ] Dependencies flow in one direction
- [ ] No circular dependencies

**Type Safety**
- [ ] Types defined for all public APIs
- [ ] No unqualified `any`
- [ ] Nullable types explicitly marked

**Testing**
- [ ] Refactored code has tests
- [ ] Tests cover edge cases
- [ ] All tests pass before and after

---

## Quick Reference: Refactoring Operations

| Operation | When to Use |
|-----------|-------------|
| Extract Method | Code fragment → named function |
| Extract Class | Behavior that belongs elsewhere |
| Extract Interface | Decouple from implementation |
| Inline Method | Wrapper adds no value |
| Pull Up / Push Down | Move to right level of hierarchy |
| Introduce Parameter Object | >3 related params |
| Replace Conditional with Polymorphism | Switch/if on type codes |
| Replace Magic Number with Constant | Any unexplained literal |
| Decompose Conditional | Complex boolean expressions |
| Replace Nested Conditional with Guard Clauses | Arrow code |
| Introduce Null Object | Repeated null checks |
| Replace Type Code with Enum | String/int type discrimination |
| Replace Inheritance with Delegation | Composition over inheritance |
