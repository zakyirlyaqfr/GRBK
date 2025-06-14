import 'package:flutter/cupertino.dart';
import '../models/cart_item.dart';
import '../theme/app_theme.dart';

class CartItemWidget extends StatelessWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              cartItem.product.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: CupertinoColors.systemGrey5,
                  child: const Icon(CupertinoIcons.photo, color: CupertinoColors.systemGrey),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.product.name,
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  cartItem.product.category,
                  style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle.copyWith(
                    color: CupertinoColors.systemGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${_formatPrice(cartItem.product.price)}',
                  style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Quantity Controls and Remove Button
          Column(
            children: [
              // Remove Button
              CupertinoButton(
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.delete, color: CupertinoColors.destructiveRed, size: 20),
              ),
              
              // Quantity Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuantityButton(
                    context,
                    CupertinoIcons.minus,
                    () => onQuantityChanged(cartItem.quantity - 1),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: CupertinoColors.systemGrey4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${cartItem.quantity}',
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    ),
                  ),
                  _buildQuantityButton(
                    context,
                    CupertinoIcons.plus,
                    () => onQuantityChanged(cartItem.quantity + 1),
                  ),
                ],
              ),
              
              // Total Price
              Text(
                'Rp ${_formatPrice(cartItem.totalPrice)}',
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(BuildContext context, IconData icon, VoidCallback onPressed) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 32,
      onPressed: onPressed,
      child: Icon(icon, size: 18),
    );
  }

  String _formatPrice(double price) {
    return price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}
