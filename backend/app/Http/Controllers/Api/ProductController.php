<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Product\StoreCategoryRequest;
use App\Http\Requests\Product\StoreProductRequest;
use App\Http\Requests\Product\UpdateCategoryRequest;
use App\Http\Requests\Product\UpdateProductRequest;
use App\Http\Resources\CategoryResource;
use App\Http\Resources\ProductResource;
use App\Models\Category;
use App\Models\Product;
use App\Services\ProductService;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    use ApiResponse;

    public function __construct(private ProductService $service) {}

    // ---------- Categories ----------

    public function categories(): JsonResponse
    {
        return $this->success(CategoryResource::collection(Category::withCount('products')->orderBy('name')->get()));
    }

    public function showCategory(Category $category): JsonResponse
    {
        return $this->success(CategoryResource::make($category->loadCount('products')));
    }

    public function storeCategory(StoreCategoryRequest $request): JsonResponse
    {
        $cat = $this->service->createCategory($request->validated());
        return $this->created(CategoryResource::make($cat), 'Kategori berhasil ditambahkan');
    }

    public function updateCategory(UpdateCategoryRequest $request, Category $category): JsonResponse
    {
        $cat = $this->service->updateCategory($category, $request->validated());
        return $this->success(CategoryResource::make($cat), 'Kategori berhasil diperbarui');
    }

    public function destroyCategory(Category $category): JsonResponse
    {
        $category->delete();
        return $this->success(null, 'Kategori berhasil dihapus');
    }

    // ---------- Products ----------

    public function index(Request $request): JsonResponse
    {
        $q = Product::with('category');
        if ($request->filled('category_id')) $q->where('category_id', $request->category_id);
        if ($request->filled('search')) $q->where('name', 'like', '%' . $request->search . '%');
        if ($request->boolean('only_available', true)) $q->available();
        $items = $q->orderBy('name')->paginate(20);
        return $this->success(ProductResource::collection($items)->response()->getData(true));
    }

    public function show(Product $product): JsonResponse
    {
        return $this->success(ProductResource::make($product->load('category')));
    }

    public function store(StoreProductRequest $request): JsonResponse
    {
        $product = $this->service->createProduct($request->validated(), $request->file('image'));
        return $this->created(ProductResource::make($product), 'Produk berhasil ditambahkan');
    }

    public function update(UpdateProductRequest $request, Product $product): JsonResponse
    {
        $product = $this->service->updateProduct($product, $request->validated(), $request->file('image'));
        return $this->success(ProductResource::make($product), 'Produk berhasil diperbarui');
    }

    public function destroy(Product $product): JsonResponse
    {
        $this->service->deleteProduct($product);
        return $this->success(null, 'Produk berhasil dihapus');
    }
}
