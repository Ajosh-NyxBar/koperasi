<?php

namespace App\Traits;

use Illuminate\Http\JsonResponse;

trait ApiResponse
{
    protected function success(mixed $data = null, string $message = '', int $status = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data'    => $data,
        ], $status);
    }

    protected function error(string $message, int $status = 400, mixed $errors = null): JsonResponse
    {
        $payload = ['success' => false, 'message' => $message, 'data' => null];
        if ($errors) $payload['errors'] = $errors;
        return response()->json($payload, $status);
    }

    protected function created(mixed $data = null, string $message = 'Berhasil dibuat'): JsonResponse
    {
        return $this->success($data, $message, 201);
    }
}
