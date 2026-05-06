<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Resources\NotificationResource;
use App\Traits\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    use ApiResponse;

    public function index(Request $request): JsonResponse
    {
        $items = $request->user()->notifications()->paginate(20);
        return $this->success([
            'unread_count' => $request->user()->unreadNotifications()->count(),
            'items'        => NotificationResource::collection($items)->response()->getData(true),
        ]);
    }

    public function markAsRead(Request $request, string $id): JsonResponse
    {
        $notification = $request->user()->notifications()->where('id', $id)->first();
        if (!$notification) return $this->error('Notifikasi tidak ditemukan', 404);
        $notification->markAsRead();
        return $this->success(null, 'Notifikasi ditandai dibaca');
    }

    public function markAllAsRead(Request $request): JsonResponse
    {
        $request->user()->unreadNotifications->markAsRead();
        return $this->success(null, 'Semua notifikasi ditandai dibaca');
    }
}
