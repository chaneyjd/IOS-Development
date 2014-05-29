//
//  Shader.fsh
//  cogl
//
//  Created by Jason Chaney on 5/25/14.
//  Copyright (c) 2014 Chaney Household. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
