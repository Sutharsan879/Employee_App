<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreEmployeeRequest;
use App\Http\Requests\UpdateEmployeeRequest;
use App\Http\Resources\EmployeeResource;
use App\Models\Employee;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

class EmployeeController extends Controller
{
    public function index(Request $request): AnonymousResourceCollection
    {
        $query = Employee::query();

        if ($search = $request->query('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                    ->orWhere('department', 'like', "%{$search}%")
                    ->orWhere('designation', 'like', "%{$search}%");
            });
        }

        match ($request->query('filter')) {
            'active' => $query->active(),
            'flagged' => $query->flagged(),
            default => null,
        };

        $employees = $query->orderBy('name')->paginate(20);

        return EmployeeResource::collection($employees);
    }

    public function stats(): JsonResponse
    {
        $employees = Employee::all();

        return response()->json([
            'total' => $employees->count(),
            'active' => $employees->where('is_active', true)->count(),
            'flagged' => $employees->filter(fn (Employee $employee) => $employee->is_flagged)->count(),
        ]);
    }

    public function show(int $id): EmployeeResource|JsonResponse
    {
        $employee = Employee::find($id);

        if (! $employee) {
            return response()->json(['message' => 'Employee not found.'], 404);
        }

        return new EmployeeResource($employee);
    }

    public function store(StoreEmployeeRequest $request): JsonResponse
    {
        $employee = Employee::create($request->validated());

        return (new EmployeeResource($employee))
            ->response()
            ->setStatusCode(201);
    }

    public function update(UpdateEmployeeRequest $request, int $id): EmployeeResource|JsonResponse
    {
        $employee = Employee::find($id);

        if (! $employee) {
            return response()->json(['message' => 'Employee not found.'], 404);
        }

        $employee->update($request->validated());

        return new EmployeeResource($employee->fresh());
    }

    public function destroy(int $id): JsonResponse
    {
        $employee = Employee::find($id);

        if (! $employee) {
            return response()->json(['message' => 'Employee not found.'], 404);
        }

        $employee->delete();

        return response()->json(null, 204);
    }
}
