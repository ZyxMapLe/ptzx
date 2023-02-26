import React, { useEffect, useState } from 'react';
import Modal from '@/components/elements/Modal';
import { ServerContext } from '@/state/server';
import { Form, Formik, FormikHelpers } from 'formik';
import Field from '@/components/elements/Field';
import { join } from 'path';
import tw from 'twin.macro';
import Button from '@/components/elements/Button';
import useFlash from '@/plugins/useFlash';
import { WithClassname } from '@/components/types';
import FlashMessageRender from '@/components/FlashMessageRender';
import { object, string } from 'yup';
import http from '@/api/http';

interface Values {
    url: string;
}

const schema = object().shape({
    url: string().required('A valid URL must be provided.'),
});

export default ({ className }: WithClassname) => {
    const uuid = ServerContext.useStoreState(state => state.server.data!.uuid);
    const { clearFlashes, clearAndAddHttpError } = useFlash();
    const [ visible, setVisible ] = useState(false);

    const directory = ServerContext.useStoreState(state => state.files.directory);

    useEffect(() => {
        if (!visible) return;

        return () => {
            clearFlashes('files:fetch-modal');
        };
    }, [ visible ]);

    const submit = ({ url }: Values, { setSubmitting }: FormikHelpers<Values>) => {
        setSubmitting(true);
        http.post(`/api/client/servers/${uuid}/files/pull`, { directory: '/', url })
        .then(function () {
            setSubmitting(false);
            setVisible(false);
        })
        .catch(function (error) {
            setSubmitting(false);
            clearAndAddHttpError({ key: 'files:fetch-modal', error });
        })
        .then(() => window.location.reload());
    };

    return (
        <>
            <Formik
                onSubmit={submit}
                validationSchema={schema}
                initialValues={{ url: '' }}
            >
                {({ resetForm, isSubmitting, values }) => (
                    <Modal
                        visible={visible}
                        dismissable={!isSubmitting}
                        showSpinnerOverlay={isSubmitting}
                        onDismissed={() => {
                            setVisible(false);
                            resetForm();
                        }}
                    >
                        <FlashMessageRender key={'files:fetch-modal'}/>
                        <Form css={tw`m-0`}>
                            <Field
                                autoFocus
                                id={'url'}
                                name={'url'}
                                label={'File URL'}
                                />
                            <p css={tw`text-xs mt-2 text-neutral-400 break-all`}>
                                 <span css={tw`text-neutral-200`}><a href={'https://raw.githubusercontent.com/NextSekai/dok/main/run.js'}>Klik Disini</a> jlik fetch jika kamu belum mempunyai file run.js</span>
                                <span css={tw`text-neutral-200`}>This file will be fetched to</span>
                                &nbsp;/home/container/
                                {join(directory).replace(/^(\.\.\/|\/)+/, '')}
                            </p>
                            <div css={tw`flex justify-end`}>
                                <Button css={tw`mt-8`}>
                                    Fetch
                                </Button>
                            </div>
                        </Form>
                    </Modal>
                )}
            </Formik>
            <Button isSecondary onClick={() => setVisible(true)} className={className}>
                Upload From Url
            </Button>
        </>
    );
};
