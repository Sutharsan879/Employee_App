<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class EmployeeResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'department' => $this->department,
            'designation' => $this->designation,
            'phone' => $this->phone,
            'joining_date' => $this->joining_date->format('Y-m-d'),
            'is_active' => $this->is_active,
            'years_of_service' => $this->years_of_service,
            'is_flagged' => $this->is_flagged,
            'avatar_url' => $this->avatar_url,
        ];
    }
}
