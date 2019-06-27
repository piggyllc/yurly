<?php declare(strict_types=1);

namespace Site1\Controllers;

use Yurly\Core\Controller;
use Yurly\Inject\Request\Get;
use Yurly\Inject\Response\Json;

class Index extends Controller
{

    public function routeDefault(Get $request, Json $response): array
    {

        return ['result' => 'site1'];

    }

}
