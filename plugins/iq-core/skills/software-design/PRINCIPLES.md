# Core Software Principles

## SOLID Principles

### Single Responsibility Principle (SRP)
A class, module, or function should have one, and only one, reason to change.
- **Do:** Split large functions into smaller, focused ones.
- **Don't:** Have a "User" class that handles auth, database, and email sending.

### Open/Closed Principle (OCP)
Software entities should be open for extension, but closed for modification.
- **Do:** Use interfaces and dependency injection to allow behavior changes.
- **Don't:** Modify existing stable code to add new features (use inheritance or composition instead).

### Liskov Substitution Principle (LSP)
Objects of a superclass shall be replaceable with objects of its subclasses without breaking the application.

### Interface Segregation Principle (ISP)
Clients should not be forced to depend upon interfaces that they do not use.
- **Do:** Create small, specific interfaces.
- **Don't:** Create massive "God interfaces".

### Dependency Inversion Principle (DIP)
High-level modules should not depend on low-level modules. Both should depend on abstractions.
- **Do:** Depend on interfaces/abstract classes.
- **Don't:** Hardcode dependencies (e.g., `new Database()` inside a service).

## Other Key Principles

### DRY (Don't Repeat Yourself)
Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.
- Extract common logic into helpers or hooks.
- Don't copy-paste code.

### KISS (Keep It Simple, Stupid)
Most systems work best if they are kept simple rather than made complicated.
- Avoid premature optimization.
- Avoid over-engineering (YAGNI - You Ain't Gonna Need It).

### Composition over Inheritance
Prefer object composition to class inheritance.
- Use React hooks for sharing logic.
- Use dependency injection in NestJS.
