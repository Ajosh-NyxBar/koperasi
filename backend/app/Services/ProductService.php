<?php

namespace App\Services;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;

class ProductService
{
    public function createCategory(array $data): Category
    {
        return Category::create($data + ['is_active' => $data['is_active'] ?? true]);
    }

    public function updateCategory(Category $category, array $data): Category
    {
        $category->update($data);
        return $category->fresh();
    }

    public function createProduct(array $data, ?UploadedFile $image = null): Product
    {
        if ($image) {
            $data['image'] = $image->store('products', 'public');
        }
        $data['is_available'] = $data['is_available'] ?? true;
        $data['stock'] = $data['stock'] ?? 0;
        return Product::create($data)->load('category');
    }

    public function updateProduct(Product $product, array $data, ?UploadedFile $image = null): Product
    {
        if ($image) {
            if ($product->image) Storage::disk('public')->delete($product->image);
            $data['image'] = $image->store('products', 'public');
        }
        $product->update($data);
        return $product->fresh()->load('category');
    }

    public function deleteProduct(Product $product): void
    {
        $product->delete();
    }
}
