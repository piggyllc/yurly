<?php declare(strict_types=1);

namespace Tests;

use PHPUnit\Framework\TestCase;

class ResponseTest extends TestCase
{

    public function testResponseInterface()
    {

        $this->expectOutputString('Hello world!');

        $project = new \Yurly\Core\Project('', __NAMESPACE__, 'tests', true);
        $ctx = new \Yurly\Core\Context($project);
        $response = new \Yurly\Inject\Response\Response($ctx);
        $response->setResponseClass(new \Yurly\Inject\Response\Html($ctx))
                 ->setViewParams('Hello world!')
                 ->render();

    }

    public function testJsonResponseInterface()
    {

        $this->expectOutputString('{"hello":"world!"}');

        $project = new \Yurly\Core\Project('', __NAMESPACE__, 'tests', true);
        $ctx = new \Yurly\Core\Context($project);
        $response = new \Yurly\Inject\Response\Response($ctx);
        $response->setResponseClass(new \Yurly\Inject\Response\Json($ctx))
                 ->setViewParams(['hello' => 'world!'])
                 ->render();

    }

}
