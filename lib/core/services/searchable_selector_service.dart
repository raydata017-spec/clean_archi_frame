import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/config/dimensions.dart';
import '../utils/extensions/context_extension.dart';

// --------------------------------------------------------------------------
// 1. PUBLIC GENERIC SERVICE CLASS
// --------------------------------------------------------------------------
class SearchableSelectorService {
  /// A simple function to show a searchable selector bottom sheet for any list of type T.
  ///
  /// * [itemFilter]: Custom search logic. If null, defaults to checking if the string contains the query.
  /// * [getSearchString]: If you don't provide a custom filter, use this to tell the service
  ///   which string property to search on (e.g., (user) => user.name).
  static Future<T?> showSearchableSelectorSheet<T>(
    BuildContext context, {
    required String title,
    required List<T> items,
    required Widget Function(T item) itemBuilder,
    bool Function(T item, String query)? itemFilter,
    String Function(T item)? getSearchString,
    Function(T selectedItem)?
    onSelected, // Made optional to allow standard await usage
  }) async {
    // 1. Determine the filter function (Default or Custom)
    final finalItemFilter =
        itemFilter ??
        _getDefaultItemFilter<T>(getSearchString: getSearchString);

    final T? selectedItem = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // Ensures sheet respects top notches/status bars
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height * 0.9, // 90% screen height
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusMd),
        ),
      ),
      backgroundColor: context.colorScheme.surface,
      builder: (BuildContext context) {
        return _GenericSearchableSheet<T>(
          title: title,
          items: items,
          itemBuilder: itemBuilder,
          itemFilter: finalItemFilter,
        );
      },
    );

    // Execute the callback if provided and an item was selected
    if (selectedItem != null && onSelected != null) {
      onSelected(selectedItem);
    }

    return selectedItem;
  }

  // --------------------------------------------------------------------------
  // 2. PRIVATE GENERIC DEFAULT FILTER LOGIC
  // --------------------------------------------------------------------------

  static bool Function(T item, String query) _getDefaultItemFilter<T>({
    String Function(T item)? getSearchString,
  }) {
    return (T item, String query) {
      final normalizedQuery = query.toLowerCase();
      if (normalizedQuery.isEmpty) return true;

      final searchString = getSearchString != null
          ? getSearchString(item).toLowerCase()
          : item.toString().toLowerCase();

      return searchString.contains(normalizedQuery);
    };
  }
}

// --------------------------------------------------------------------------
// 3. INTERNAL STATEFUL WIDGET
// --------------------------------------------------------------------------

class _GenericSearchableSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final Widget Function(T item) itemBuilder;
  final bool Function(T item, String query) itemFilter;

  const _GenericSearchableSheet({
    super.key,
    required this.title,
    required this.items,
    required this.itemBuilder,
    required this.itemFilter,
  });

  @override
  State<_GenericSearchableSheet<T>> createState() =>
      _GenericSearchableSheetState<T>();
}

class _GenericSearchableSheetState<T>
    extends State<_GenericSearchableSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where((item) => widget.itemFilter(item, query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Using DraggableScrollableSheet logic indirectly via Column/Expanded
    // to respect the constraints passed by showModalBottomSheet
    return Padding(
      // Add bottom padding for keyboard visibility
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // --- HEADER ---
          Padding(
            padding: const EdgeInsets.only(
              left: AppSizes.paddingMarginMd,
              top: AppSizes.paddingMarginSm,
              right: AppSizes.paddingMarginSm,
              bottom: AppSizes.paddingMarginSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => context.pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // --- SEARCH BAR ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.paddingMarginMd,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              style: TextStyle(color: context.colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: AppSizes.paddingMarginMd,
                ),
                fillColor: context.colorScheme.onSurface.withValues(alpha: 0.05),
                filled: true,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: AppSizes.iconSm,
                          color: context.colorScheme.onSurface.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.borderRadiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.spaceBtwTexts),

          // --- LIST ---
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Text(
                      'No results found',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    itemCount: _filteredItems.length,
                    separatorBuilder: (context, index) => Divider(
                      height: AppSizes.dividerHeight,
                      indent: AppSizes.paddingMarginMd,
                      color: context.colorScheme.onSurface.withValues(
                        alpha: 0.2,
                      ),
                    ),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      return InkWell(
                        onTap: () => context.pop(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.paddingMarginMd,
                          ),
                          child: widget.itemBuilder(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
