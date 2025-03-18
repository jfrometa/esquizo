// COMPONENT 3: EnhancedCateringItemCard
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_card.dart';
import 'package:starter_architecture_flutter_firebase/src/screens/catering/catering_item.dart';


// COMPONENT 3: EnhancedCateringItemCard
class EnhancedCateringItemCard extends StatefulWidget {
  final CateringItem item;
  final bool isSelected;
  final int currentQuantity;
  final Function(int) onQuantityChanged;
  final TextEditingController sideRequestController;

  const EnhancedCateringItemCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.currentQuantity,
    required this.onQuantityChanged,
    required this.sideRequestController,
  });

  @override
  State<EnhancedCateringItemCard> createState() => _EnhancedCateringItemCardState();
}

class _EnhancedCateringItemCardState extends State<EnhancedCateringItemCard> {
  bool _expanded = false;
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: widget.isSelected ? 3 : 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: widget.isSelected
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content area (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            widget.item.img,
                            fit: BoxFit.cover,
                          ),
                          if (widget.isSelected)
                            Container(
                              color: colorScheme.primary.withOpacity(0.3),
                              child: Center(
                                child: CircleAvatar(
                                  backgroundColor: colorScheme.primary,
                                  child: Text(
                                    widget.currentQuantity.toString(),
                                    style: TextStyle(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.item.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              '\$${widget.item.pricing}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Description
                        Text(
                          widget.item.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Tags row
                        Wrap(
                          spacing: 8,
                          children: [
                            // Cuisine type tag
                            _buildTag(
                              widget.item.category,
                              Icons.category,
                              colorScheme.secondary,
                              colorScheme.onSecondary,
                            ),
                            
                            // Portions tag
                            _buildTag(
                              '${widget.item.peopleCount} porciones',
                              Icons.people,
                              colorScheme.tertiary,
                              colorScheme.onTertiary,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable section (details and quantity selector)
          AnimatedCrossFade(
            firstChild: const SizedBox(height: 0),
            secondChild: _buildExpandedSection(colorScheme, theme),
            crossFadeState: _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
          
          // Controls area (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Expand/collapse button
                TextButton.icon(
                  icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                  label: Text(_expanded ? 'Menos' : 'Más información'),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    setState(() {
                      _expanded = !_expanded;
                    });
                  },
                ),
                
                // Quantity controls
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.isSelected ? Icons.remove_circle : Icons.add_circle_outline,
                        color: widget.isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        if (widget.isSelected) {
                          widget.onQuantityChanged(widget.currentQuantity - 1);
                        } else {
                          widget.onQuantityChanged(1);
                        }
                      },
                    ),
                    
                    if (widget.isSelected)
                      Row(
                        children: [
                          Text(
                            widget.currentQuantity.toString(),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.add_circle,
                              color: colorScheme.primary,
                            ),
                            onPressed: () {
                              widget.onQuantityChanged(widget.currentQuantity + 1);
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildExpandedSection(ColorScheme colorScheme, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          top: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
          bottom: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          
          // Ingredients
          if (widget.item.ingredients.isNotEmpty) ...[
            Text(
              'Ingredientes:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.item.ingredients.join(', '),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Special requests
          Text(
            'Solicitudes especiales:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          TextField(
            controller: widget.sideRequestController,
            decoration: InputDecoration(
              hintText: 'Ej: Sin picante, sin cebolla...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              isDense: true,
            ),
            maxLines: 2,
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 12),
        ],
      ),
    );
  }
  
  Widget _buildTag(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: backgroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: backgroundColor,
            ),
          ),
        ],
      ),
    );
  }
}