# Business ID Migration Plan

## Collections That Need Business ID Filtering

### ✅ Already Using Business ID:
- `businesses/{businessId}/mealPlans`
- `businesses/{businessId}/mealPlanCategories`
- `businesses/{businessId}/consumedItems`
- `businesses/{businessId}/mealPlanItems`
- `businesses/{businessId}/resources` (tables)
- `businesses/{businessId}/orders`
- `businesses/{businessId}/reservations`
- `businesses/{businessId}/seasonal_menus`
- `businesses/{businessId}/menu_categories`
- `businesses/{businessId}/menu_items`

### 🔧 Need to be Updated:

#### Core Collections:
1. **orders** - Currently queries without business ID
2. **cateringOrders** - Currently queries without business ID
3. **cateringCategories** - Currently queries without business ID
4. **cateringItems** - Currently queries without business ID
5. **cateringPackages** - Currently queries without business ID
6. **cateringDishes** - Currently queries without business ID
7. **staff** - Currently queries without business ID
8. **tables** - Some queries still use root collection
9. **users** (staff management) - Needs business relationship filtering
10. **subscriptions** - Currently queries without business ID
11. **meals** - Currently queries without business ID

#### Exception Collections (Platform-wide):
- `userPreferences` ✅ (user-specific, no business filtering needed)
- `business_relationships` ✅ (manages business-user relationships)
- `admins` ✅ (platform admins)

## Migration Strategy

### Phase 1: Update Data Models
- Add `businessId` field to all affected models
- Update `toFirestore()` methods to include `businessId`
- Update `fromFirestore()` methods to handle `businessId`

### Phase 2: Update Service Layer
- Modify all Firestore queries to include business ID filtering
- Update collection references to use business-scoped paths where appropriate
- Add business ID validation

### Phase 3: Update Providers and Repositories
- Inject business ID from `currentBusinessIdProvider`
- Update all repository methods to include business filtering
- Add business context to all catering, order, and staff operations

### Phase 4: Staff Management Enhancement
- Add business relationship checks for staff access
- Implement role-based access within business context
- Add business-specific staff hierarchy (admins, waiters, cooks, supervisors, cashiers)

## Implementation Priority

1. **High Priority**: Orders, Catering (core business operations)
2. **Medium Priority**: Staff management, Tables
3. **Low Priority**: Legacy data migration scripts
